import '../../../core/services/inference_service.dart';

class TriageReportViewData {
  const TriageReportViewData({
    required this.imagePath,
    required this.predictedGroups,
    required this.triageLevel,
    required this.contextData,
    required this.explanation,
    this.geminiError,
  });

  final String imagePath;

  final List<PredictedGroup> predictedGroups;

  final String triageLevel;

  final Map<String, dynamic> contextData;

  final String explanation;

  final String? geminiError;
}