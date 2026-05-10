import '../../../core/services/inference_service.dart';

enum TriageOutcome {
  nonurgent,
  expedited,
  urgent,
}

class TriageDecision {
  const TriageDecision({
    required this.outcome,
    required this.reason,
    required this.disclaimer,
    this.clinicalReviewRecommended = false,
  });

  final TriageOutcome outcome;
  final String reason;
  final String disclaimer;

  final bool clinicalReviewRecommended;
}

class TriageLogic {

  static TriageDecision evaluate({
    required List<PredictedGroup> groups,
    required Map<String, dynamic> contextData,
  }) {

    final top1 = groups.first;

    final top2 =
    groups.length > 1
        ? groups[1]
        : null;

    final top1Label =
    _normalizeGroup(
      top1.group,
    );

    final top2Label =
    top2 != null
        ? _normalizeGroup(
      top2.group,
    )
        : '';

    final confidence =
    top1.confidence;

    final conditionSymptoms =
    List<String>.from(
      contextData['condition_symptoms'] ?? [],
    );

    final otherSymptoms =
    List<String>.from(
      contextData['other_symptoms'] ?? [],
    );

    final bodyArea =
    List<String>.from(
      contextData['body_area'] ?? [],
    );

    // ----------------------------------
    // USER SYMPTOMS / FLAGS
    // ----------------------------------

    final hasPain =
    conditionSymptoms.contains(
      'Pain',
    );

    final hasBleeding =
    conditionSymptoms.contains(
      'Bleeding',
    );

    final hasDarkening =
    conditionSymptoms.contains(
      'Darkening',
    );

    final hasFever =
    otherSymptoms.contains(
      'Fever',
    );

    final hasFatigue =
    otherSymptoms.contains(
      'Fatigue',
    );

    final hasMouthSores =
    otherSymptoms.contains(
      'Mouth sores',
    );

    final hasShortnessOfBreath =
    otherSymptoms.contains(
      'Shortness of breath',
    );

    final hasHeadOrNeck =
    bodyArea.contains(
      'Head or Neck',
    );

    final hasGenital =
    bodyArea.contains(
      'Genitalia or Groin',
    );

    // ----------------------------------
    // IMMEDIATE URGENT OVERRIDES
    // ----------------------------------

    if (hasShortnessOfBreath) {

      return TriageDecision(
        outcome: TriageOutcome.urgent,
        reason:
        'Breathing-related symptoms may require urgent medical assessment.',
        disclaimer: _disclaimer,
      );
    }

    // ----------------------------------
    // DEFAULT TRIAGE MAPPING
    // ----------------------------------

    TriageOutcome outcome;
    String reason;

    switch (top1Label) {

      case 'Acneiform':

        outcome =
            TriageOutcome.nonurgent;

        reason =
        'Likely acneiform pattern. Routine outpatient assessment is generally appropriate.';
        break;

      case 'Eczematous_Dermatitis':

        outcome =
            TriageOutcome.nonurgent;

        reason =
        'Likely eczematous or dermatitis pattern. Routine assessment is generally appropriate.';
        break;

      case 'Fungal':

        outcome =
            TriageOutcome.nonurgent;

        reason =
        'Likely fungal pattern. Routine assessment is generally appropriate.';
        break;

      case 'Papulosquamous_Lichenoid':

        outcome =
            TriageOutcome.nonurgent;

        reason =
        'Likely papulosquamous or lichenoid pattern. Routine dermatology assessment is appropriate.';
        break;

      case 'Bacterial_Follicular':

        outcome =
            TriageOutcome.expedited;

        reason =
        'Likely bacterial or follicular pattern. Prompt assessment is recommended.';
        break;

      case 'Urticarial_Hypersensitivity':

        outcome =
            TriageOutcome.expedited;

        reason =
        'Likely urticarial or hypersensitivity pattern. Prompt assessment is recommended.';
        break;

      case 'Viral':

        outcome =
            TriageOutcome.expedited;

        reason =
        'Likely viral eruption pattern. Prompt assessment is recommended.';
        break;

      case 'Drug_Vasculitic_Purpuric':

        outcome =
            TriageOutcome.urgent;

        reason =
        'Higher-risk caution pattern detected. Urgent medical assessment is recommended.';
        break;

      default:

        outcome =
            TriageOutcome.expedited;

        reason =
        'Clinical review is recommended due to prediction uncertainty.';
    }

    // ----------------------------------
    // ESCALATION RULES
    // ----------------------------------

    // bacterial + fever
    if (
    top1Label ==
        'Bacterial_Follicular' &&
        hasFever
    ) {

      outcome =
          TriageOutcome.urgent;

      reason =
      'Fever with bacterial-pattern symptoms may require urgent medical assessment.';
    }

    // viral + head/neck
    if (
    top1Label == 'Viral' &&
        hasHeadOrNeck
    ) {

      outcome =
          TriageOutcome.urgent;

      reason =
      'Head or neck involvement with viral-pattern symptoms may require urgent assessment.';
    }

    // dermatitis escalation
    if (
    top1Label ==
        'Eczematous_Dermatitis' &&
        (
            hasPain ||
                hasHeadOrNeck ||
                hasGenital
        )
    ) {

      outcome =
          TriageOutcome.expedited;

      reason =
      'Symptoms or affected body areas suggest more prompt clinical review may be appropriate.';
    }

    // fungal escalation
    if (
    top1Label == 'Fungal' &&
        hasHeadOrNeck
    ) {

      outcome =
          TriageOutcome.expedited;

      reason =
      'Head or neck fungal involvement may require prompt clinical review.';
    }

    // caution + mouth sores
    if (
    top1Label ==
        'Drug_Vasculitic_Purpuric' &&
        hasMouthSores
    ) {

      outcome =
          TriageOutcome.urgent;

      reason =
      'Mouth sores with caution-pattern findings may require urgent medical evaluation.';
    }

    // bleeding + darkening escalation
    if (
    hasBleeding &&
        hasDarkening
    ) {

      outcome =
          TriageOutcome.urgent;

      reason =
      'Bleeding and darkening symptoms may require urgent clinical assessment.';
    }

    // systemic symptoms escalation
    if (
    hasFever &&
        hasFatigue
    ) {

      if (
      outcome !=
          TriageOutcome.urgent
      ) {

        outcome =
            TriageOutcome.expedited;
      }

      reason =
      'Systemic symptoms may require earlier medical review.';
    }

    // ----------------------------------
    // LOW CONFIDENCE SAFETY
    // ----------------------------------

    final lowConfidence =
        confidence < 0.40;

    if (lowConfidence) {

      if (
      outcome ==
          TriageOutcome.nonurgent
      ) {

        outcome =
            TriageOutcome.expedited;
      }

      reason =
      '$reason Clinical review is recommended because prediction confidence is low.';
    }

    // ----------------------------------
    // TOP-2 SAFETY CHECK
    // ----------------------------------

    if (
    top2Label ==
        'Drug_Vasculitic_Purpuric'
    ) {

      if (
      outcome ==
          TriageOutcome.nonurgent
      ) {

        outcome =
            TriageOutcome.expedited;
      }

      reason =
      '$reason A higher-risk alternative pattern remains possible.';
    }

    return TriageDecision(
      outcome: outcome,
      reason: reason,
      disclaimer: _disclaimer,
      clinicalReviewRecommended:
      lowConfidence,
    );
  }

  static String _normalizeGroup(
      String label,
      ) {

    return label
        .replaceAll(
      '_LowUrgency',
      '',
    )
        .replaceAll(
      '_Caution',
      '',
    )
        .trim();
  }

  static const String _disclaimer =
      'SkinBuddy is a triage support tool and does not provide a medical diagnosis.';
}