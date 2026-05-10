import 'package:cloud_firestore/cloud_firestore.dart';

class TriageRecord {
  const TriageRecord({
    required this.id,
    required this.bodyPart,
    required this.triageLevel,
    required this.predictedGroup,
    required this.explanation,
    required this.imgUrl,
    required this.timestamp,
  });

  final String id;
  final String bodyPart;
  final String predictedGroup;
  final DateTime timestamp;
  final String triageLevel;
  final String imgUrl;
  final String explanation;

  factory TriageRecord.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    final timestamp = data['timestamp'];
    final legacyCreatedAt = data['createdAt'];
    final explanation = (data['explanation'] as String? ?? '').trim();

    return TriageRecord(
      id: doc.id,

      bodyPart: (data['body_area'] as List?)?.isNotEmpty == true
          ? (data['body_area'] as List)
          .map((e) => e.toString())
          .join(', ')
          : ((data['label'] as String?)?.trim().isNotEmpty == true
          ? (data['label'] as String).trim()
          : 'Unknown area'),

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

      explanation: explanation.isNotEmpty
          ? explanation
          : 'No explanation available.',
    );
  }

  static String _getHighestConfidenceGroup(Map<String, dynamic> data) {
    final groups = data['predicted_groups'];

    if (groups is List && groups.isNotEmpty) {
      String bestName = 'Awaiting prediction';
      double highestConfidence = -1;

      for (final item in groups) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);

          final confidence =
              (map['confidence'] as num?)?.toDouble() ?? 0;

          final name =
              (map['name'] as String?)?.trim() ?? '';

          if (name.isNotEmpty && confidence > highestConfidence) {
            highestConfidence = confidence;
            bestName = name;
          }
        }
      }

      return bestName;
    }

    return 'Awaiting prediction';
  }
}