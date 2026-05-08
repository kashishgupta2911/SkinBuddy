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
    required PredictionResult prediction,
    required String triageLevel,
    required String imagePath,

    required String relatedCategory,
    required String texture,
    required List<String> bodyArea,
    required List<String> conditionSymptoms,
    required List<String> otherSymptoms,
    required String duration,

    required String nextSteps,
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

    // Get public download URL
    final imageUrl = await storageRef.getDownloadURL();

    // Get saved user info (age range)
    final userDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    final userData = userDoc.data();
    final ageRange = userData?['age_range'] ?? '';

    // Save Firestore document
    await docRef.set({
      'img_url': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': Timestamp.now(),

      // User metadata
      'age_range': ageRange,

      // Context metadata
      'related_category': relatedCategory,
      'texture': texture,
      'body_area': bodyArea,
      'condition_symptoms': conditionSymptoms,
      'other_symptoms': otherSymptoms,
      'duration': duration,

      // Model outputs
      'triage_level': triageLevel,

      'predicted_groups': [
        {
          'name': prediction.label,
          'confidence': prediction.confidence,
        }
      ],
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
    required String modelVersion,
    bool consentToStoreImagePath = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError(
          'User must be authenticated before saving triage records.');
    }
    final uid = user.uid;

    final topGroup =
        predictedGroups.isNotEmpty ? predictedGroups.first.group : 'unknown';

    final payload = <String, dynamic>{
      'body_part': topGroup,
      'notes': decision.reason,
      'predicted_group': topGroup,
      'predicted_groups':
          predictedGroups.map((g) => g.toFirestoreMap()).toList(growable: false),
      'related_category': contextData['related_category'],
      'texture': contextData['texture'],
      'body_area': contextData['body_area'],
      'condition_symptoms': contextData['condition_symptoms'],
      'other_symptoms': contextData['other_symptoms'],
      'duration': contextData['duration'],
      'timestamp': FieldValue.serverTimestamp(),
      'triage_level': decision.outcome.name,
      'urgency': decision.outcome.name == 'urgent' ? 'Urgent' : 'Low urgency',
      'model_version': modelVersion,
      'explanation': null,
      'next_steps': null,
      'gemini_error': null,
    };

    if (consentToStoreImagePath) {
      payload['imagePath'] = imagePath;
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .add(payload);
  }

  Future<void> updateReportCopy({
    required DocumentReference<Map<String, dynamic>> ref,
    required String explanation,
    required List<String> nextSteps,
    String? geminiError,
  }) async {
    final data = <String, dynamic>{
      'explanation': explanation,
      'next_steps': nextSteps,
    };
    if (geminiError != null) {
      data['gemini_error'] = geminiError;
    } else {
      data['gemini_error'] = FieldValue.delete();
    }
    await ref.update(data);
  }
}
