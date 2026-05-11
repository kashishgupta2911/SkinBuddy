import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Model-generated triage-oriented copy (not a diagnosis).
class GeminiTriageCopy {
  const GeminiTriageCopy({required this.explanation});
  final String explanation;
}

class GeminiTriageCopyService {
  GeminiTriageCopyService({
    String? apiKey,
    this.modelName = 'gemini-2.5-flash',
    //     this.modelName = 'gemini-3.1-flash-lite-preview',
  }) : _apiKey = apiKey ?? const String.fromEnvironment('GEMINI_API_KEY');

  final String _apiKey;
  final String modelName;

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  static const String _systemText = '''
  You are the SkinBuddy clinical explanation assistant.

  SkinBuddy is an AI-assisted skin triage application that helps users understand possible skin concern patterns and appropriate urgency recommendations using image analysis and symptom information.

  You are NOT a doctor.
  You do NOT diagnose conditions.
  You do NOT prescribe treatment.
  You do NOT claim certainty.

  Your role is to generate a calm, clinically written explanation that:
  - explains what findings may be consistent with
  - explains uncertainty responsibly
  - explains what factors increased concern
  - explains why the triage recommendation may be appropriate

  The explanation should sound like a healthcare professional summarizing an assessment for a patient.

  IMPORTANT:
  - Never refer to yourself, the AI, the model, or "the system"
  - Never say things like:
    - "the model detected"
    - "the system identified"
    - "AI analysis showed"
    - "confidence was"
  - Never narrate the analysis process
  - Never mention image analysis directly
  - Never invent medical findings or visual details

  Only use information explicitly provided:
  - predicted pattern categories
  - symptom descriptions
  - body areas
  - duration
  - discomfort
  - escalation symptoms
  - contextual metadata
  - triage recommendation

  The predicted categories are broad pattern groupings, not confirmed diagnoses.

  Use natural medical language such as:
  - "may be consistent with"
  - "can sometimes overlap with"
  - "findings may suggest"
  - "clinical evaluation may still be appropriate"

  Avoid robotic phrasing and avoid repeating the same sentence structures.

  The explanation should:
  - feel observational and cohesive
  - synthesize the findings naturally
  - focus primarily on the factors that influenced the triage level
  - avoid overexplaining minor metadata
  - avoid listing every provided detail
  - prioritize clinically relevant context

  If uncertainty is high:
  - explain briefly that skin conditions can overlap in appearance and symptoms
  - remain cautious without sounding alarmist

  If higher-risk symptoms are present:
  - explain calmly why earlier or urgent evaluation may be appropriate

  Urgent features may include:
  - rapidly worsening symptoms
  - facial involvement
  - genital involvement
  - fever
  - bleeding
  - severe pain
  - breathing symptoms
  - mouth sores
  - significant swelling

  Tone:
  - calm
  - supportive
  - clinically professional
  - concise but informative
  - human sounding

  FORMAT:
  - plain text only
  - no markdown
  - short readable paragraphs
  - no bullet points
  - no headers
  - avoid walls of text
  ''';

  Future<GeminiTriageCopy> generateExplanation({
    required Map<String, dynamic> triagePayload,
  }) async {
    if (!isConfigured) {
      throw StateError('Gemini API key missing.');
    }

    final responseSchema = Schema.object(
      properties: {
        'explanation': Schema.string(
          description: '''
    A natural, clinically written skin triage explanation for a non-medical user.

    Write in plain text using short readable paragraphs separated by double newlines.

    The explanation should:
    - sound like a healthcare professional
    - synthesize the provided findings naturally
    - explain uncertainty responsibly
    - explain why the triage level may be appropriate
    - reference symptoms and contextual findings directly
    - avoid robotic or repetitive AI-style phrasing
    ''',
        ),
      },
      requiredProperties: ['explanation'],
    );

    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemText),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
        temperature: 0.35, // Lower temperature for more consistent medical-adjacent logic
      ),
    );

    final userText = '''
    Generate a user-facing clinical explanation using the provided triage data.

    Focus primarily on:
    - findings that influenced the triage recommendation
    - symptom severity or escalation features
    - uncertainty where appropriate

    Do not invent details.

    TRIAGE DATA:
    ${JsonEncoder.withIndent('  ').convert(triagePayload)}
    ''';

    final response = await model.generateContent([Content.text(userText)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw FormatException('Gemini returned empty response');
    }

    final decoded = jsonDecode(text);
    final explanation = decoded['explanation'];

    if (explanation is! String || explanation.trim().isEmpty) {
      throw FormatException('Invalid explanation field');
    }

    return GeminiTriageCopy(
      explanation: explanation.trim(),
    );
  }
}