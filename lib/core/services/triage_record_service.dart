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
    await _ensureSignedIn();
    final uid = _auth.currentUser!.uid;

    final payload = <String, dynamic>{
      'label': prediction.label,
      'confidence': prediction.confidence,
      'triageOutcome': decision.outcome.name,
      'triageReason': decision.reason,
      'modelVersion': modelVersion,
      'appVersion': '1.0.0',
      'createdAt': FieldValue.serverTimestamp(),
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

  Future<void> _ensureSignedIn() async {
    if (_auth.currentUser != null) {
      return;
    }
    await _auth.signInAnonymously();
  }
}
