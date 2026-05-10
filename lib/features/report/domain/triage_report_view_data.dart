import '../../../core/services/inference_service.dart';

/// In-memory payload for [ReportScreen] after an analysis run.
class TriageReportViewData {
  const TriageReportViewData({
    required this.imagePath,
    required this.predictedGroups,
    required this.isUrgent,
    required this.contextData,
    required this.explanation,
    this.geminiError,
  });

  final String imagePath;
  final List<PredictedGroup> predictedGroups;
  final bool isUrgent;
  final Map<String, dynamic> contextData;
  final String explanation;
  final String? geminiError;
}
