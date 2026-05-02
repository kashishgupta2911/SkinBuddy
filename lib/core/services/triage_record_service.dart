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
    required TriageDecision decision,
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
      'triage_level': decision.outcome.name,

      'predicted_groups': [
        {
          'name': prediction.label,
          'confidence': prediction.confidence,
        }
      ],

      'explanation': decision.reason,
      'next_steps': nextSteps,
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
}
