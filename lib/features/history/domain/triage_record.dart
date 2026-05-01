import 'package:cloud_firestore/cloud_firestore.dart';

class TriageRecord {
  const TriageRecord({
    required this.id,
    required this.bodyPart,
    required this.notes,
    required this.predictedGroup,
    required this.timestamp,
    required this.triageLevel,
  });

  final String id;
  final String bodyPart;
  final String notes;
  final String predictedGroup;
  final DateTime timestamp;
  final String triageLevel;
  // 'urgency' removed: database does not include this field anymore.

  factory TriageRecord.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final timestamp = data['timestamp'];
    final legacyCreatedAt = data['createdAt'];

    return TriageRecord(
      id: doc.id,
      bodyPart: (data['body_part'] as String?)?.trim().isNotEmpty == true
          ? (data['body_part'] as String).trim()
          : ((data['label'] as String?)?.trim().isNotEmpty == true
          ? (data['label'] as String).trim()
          : 'Unknown area'),
      notes: ((data['notes'] as String?) ?? (data['triageReason'] as String?) ?? '')
          .trim(),
      predictedGroup:
      ((data['predicted_group'] as String?) ?? (data['label'] as String?) ?? '')
          .trim(),
      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : legacyCreatedAt is Timestamp
          ? legacyCreatedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
      triageLevel:
      ((data['triage_level'] as String?) ?? (data['triageOutcome'] as String?) ?? '')
          .trim(),
    );
  }
}