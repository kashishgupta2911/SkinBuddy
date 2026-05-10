import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/result/domain/triage_logic.dart';
import 'inference_service.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../features/history/domain/triage_record.dart';

class TriageRecordService {
  TriageRecordService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  Future<void> saveRecord({
    required List<dynamic> predictedGroups,
    required String triageLevel,
    required String imagePath,

    required String relatedCategory,
    required String texture,
    required List<String> bodyArea,
    required List<String> conditionSymptoms,
    required List<String> otherSymptoms,
    required String duration
  }) async {

    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'User must be authenticated before saving triage records.',
      );
    }

    final uid = user.uid;

    // Create Firestore document ID first
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .doc();

    // Firebase Storage path
    final storageRef = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('triage_records')
        .child(docRef.id)
        .child('input_image.jpg');

    // Upload image
    await storageRef.putFile(File(imagePath));

    // Get public image URL
    final imageUrl =
    await storageRef.getDownloadURL();

    // User age range
    final userDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    final userData = userDoc.data();

    final ageRange =
        userData?['age_range'] ?? '';

    // Save Firestore document
    await docRef.set({
      'img_url': imageUrl,

      'timestamp':
      FieldValue.serverTimestamp(),

      'createdAt': Timestamp.now(),

      // User metadata
      'age_range': ageRange,

      // Context metadata
      'related_category':
      relatedCategory,

      'texture': texture,

      'body_area': bodyArea,

      'condition_symptoms':
      conditionSymptoms,

      'other_symptoms':
      otherSymptoms,

      'duration': duration,

      // Model outputs
      'triage_level': triageLevel,

      'predicted_groups':
      predictedGroups,
    });
  }

  Future<TriageRecord> getLatestRecord() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User not authenticated.');
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('triage_records')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw StateError('No triage records found.');
    }

    return TriageRecord.fromFirestore(snapshot.docs.first);
  }

  /// Full triage report for the scan → context → analyze flow (Gemini fields updated later).
  Future<DocumentReference<Map<String, dynamic>>> createReport({
    required List<PredictedGroup> predictedGroups,
    required TriageDecision decision,
    required Map<String, dynamic> contextData,
    required String imagePath,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError(
        'User must be authenticated before saving triage records.',
      );
    }

    final uid = user.uid;

    // CREATE DOCUMENT FIRST
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .doc();

    // UPLOAD IMAGE
    final storageRef = _storage
        .ref()
        .child('users')
        .child(uid)
        .child('triage_records')
        .child(docRef.id)
        .child('input_image.jpg');

    await storageRef.putFile(File(imagePath));

    final imageUrl = await storageRef.getDownloadURL();

    // GET USER AGE RANGE
    final userDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    final userData = userDoc.data();

    final ageRange =
        userData?['age_range'] ?? '';

    // SAVE ONLY THE FIELDS YOU WANT
    await docRef.set({
      'age_range': ageRange,

      'body_area': contextData['body_area'],

      'condition_symptoms':
          contextData['condition_symptoms'],

      'duration': contextData['duration'],

      'explanation': '',

      'img_url': imageUrl,

      'other_symptoms':
          contextData['other_symptoms'],

      'predicted_groups':
          predictedGroups
              .map((g) => g.toFirestoreMap())
              .toList(growable: false),

      'related_category':
          contextData['related_category'],

      'texture': contextData['texture'],

      'timestamp':
          FieldValue.serverTimestamp(),

      'triage_level':
          decision.outcome.name,

      'gemini_error': null,
    });

    return docRef;
  }

  Future<void> updateReportCopy({
    required DocumentReference<Map<String, dynamic>> ref,
    required String explanation,
    String? geminiError,
  }) async {
    final data = <String, dynamic>{
      'explanation': explanation,
    };
    if (geminiError != null) {
      data['gemini_error'] = geminiError;
    } else {
      data['gemini_error'] = FieldValue.delete();
    }
    await ref.update(data);
  }
}
