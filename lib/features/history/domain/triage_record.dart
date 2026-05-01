import 'package:cloud_firestore/cloud_firestore.dart';

class TriageRecord {
  const TriageRecord({
    required this.id,
    required this.bodyPart,
    required this.notes,
    required this.predictedGroup,
    required this.timestamp,
    required this.triageLevel,
    required this.imgUrl,
  });

  final String id;
  final String bodyPart;
  final String notes;
  final String predictedGroup;
  final DateTime timestamp;
  final String triageLevel;
  final String imgUrl;

  factory TriageRecord.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final timestamp = data['timestamp'];
    final legacyCreatedAt = data['createdAt'];

    return TriageRecord(
      id: doc.id,

      bodyPart: (data['body_area'] as List?)?.isNotEmpty == true
          ? (data['body_area'] as List)
          .map((e) => e.toString())
          .join(', ')
          : ((data['label'] as String?)?.trim().isNotEmpty == true
          ? (data['label'] as String).trim()
          : 'Unknown area'),

      notes: ((data['notes'] as String?) ??
          (data['triageReason'] as String?) ??
          '')
          .trim(),

      predictedGroup: _getHighestConfidenceGroup(data),

      timestamp: timestamp is Timestamp
          ? timestamp.toDate()
          : legacyCreatedAt is Timestamp
          ? legacyCreatedAt.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),

      triageLevel: ((data['triage_level'] as String?) ??
          (data['triageOutcome'] as String?) ??
          '')
          .trim(),

      imgUrl: (data['img_url'] as String? ?? '').trim(),
    );
  }

  static String _getHighestConfidenceGroup(Map<String, dynamic> data) {
    final groups = data['predicted_groups'];

    if (groups is List && groups.isNotEmpty) {
      Map<String, dynamic>? bestGroup;
      double highestConfidence = -1;

      for (final item in groups) {
        if (item is Map<String, dynamic>) {
          final confidence =
              (item['confidence'] as num?)?.toDouble() ?? 0;

          final name =
              (item['name'] as String?)?.trim() ?? '';

          if (name.isNotEmpty && confidence > highestConfidence) {
            highestConfidence = confidence;
            bestGroup = item;
          }
        }
      }

      if (bestGroup != null) {
        return (bestGroup['name'] as String).trim();
      }
    }

    return 'Awaiting prediction';
  }
}