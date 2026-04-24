import '../../../core/services/inference_service.dart';
import '../../../core/constants/triage_config.dart';

enum TriageOutcome { urgent, nonUrgent }

class TriageDecision {
  const TriageDecision({
    required this.outcome,
    required this.reason,
    required this.disclaimer,
  });

  final TriageOutcome outcome;
  final String reason;
  final String disclaimer;
}

class TriageLogic {
  static TriageDecision evaluate(PredictionResult result) {
    final normalized = result.label.toLowerCase().trim();
    if (TriageConfig.urgentLabels.contains(normalized)) {
      return TriageDecision(
        outcome: TriageOutcome.urgent,
        reason: 'Condition category has higher risk and needs early clinician review.',
        disclaimer: _disclaimer,
      );
    }

    if (result.confidence < TriageConfig.urgentConfidenceThreshold) {
      return TriageDecision(
        outcome: TriageOutcome.urgent,
        reason: 'Model confidence is low, so conservative escalation is recommended.',
        disclaimer: _disclaimer,
      );
    }

    return TriageDecision(
      outcome: TriageOutcome.nonUrgent,
      reason: 'Pattern looks lower risk with sufficient confidence.',
      disclaimer: _disclaimer,
    );
  }

  static const String _disclaimer =
      'SkinBuddy is a triage support tool and does not provide a medical diagnosis.';
}
