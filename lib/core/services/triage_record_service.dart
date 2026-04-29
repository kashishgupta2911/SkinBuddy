import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/result/domain/triage_logic.dart';
import 'inference_service.dart';

class TriageRecordService {
  TriageRecordService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> saveRecord({
    required PredictionResult prediction,
    required TriageDecision decision,
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

    final payload = <String, dynamic>{
      'body_part': prediction.label,
      'notes': decision.reason,
      'predicted_group': prediction.label,
      'timestamp': FieldValue.serverTimestamp(),
      'triage_level': decision.outcome.name,
      'urgency': decision.outcome.name == 'urgent' ? 'Urgent' : 'Low urgency',
    };

    if (consentToStoreImagePath) {
      payload['imagePath'] = imagePath;
    }

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .add(payload);
  }
}
