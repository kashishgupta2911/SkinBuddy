import '../../../core/services/inference_service.dart';
import '../../../core/services/triage_record_service.dart';
import '../../result/domain/triage_logic.dart';

class CaptureController {
  CaptureController({
    InferenceService? inferenceService,
    TriageRecordService? triageRecordService,
  })  : _inferenceService = inferenceService ?? InferenceService(),
        _triageRecordService = triageRecordService ?? TriageRecordService();

  final InferenceService _inferenceService;
  final TriageRecordService _triageRecordService;

  Future<Map<String, dynamic>> analyze(String imagePath) async {
    final prediction = await _inferenceService.predict(imagePath);
    final decision = TriageLogic.evaluate(prediction);

    await _triageRecordService.saveRecord(
      prediction: prediction,
      decision: decision,
      imagePath: imagePath,
      relatedCategory: '',
      texture: '',
      bodyArea: [],
      conditionSymptoms: [],
      otherSymptoms: [],
      duration: '',
      nextSteps: [],
    );

    return {
      'label': prediction.label,
      'confidence': prediction.confidence,
      'triage': decision.outcome,
      'triageReason': decision.reason,
      'disclaimer': decision.disclaimer,
    };
  }
}
