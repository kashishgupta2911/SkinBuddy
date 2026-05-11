import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

/// Model-generated triage-oriented copy (not a diagnosis).
class GeminiTriageCopy {
  const GeminiTriageCopy({
    required this.explanation
  });

  final String explanation;
}

/// Calls Gemini to produce JSON `explanation` from report context.
///
/// API key: pass [apiKey] or compile with `--dart-define=GEMINI_API_KEY=your_key`.
/// Client-side keys are easy to extract; prefer a backend proxy for production.
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
You help write short, cautious text for a skin photo triage support app (not a clinician).
Rules:
- Never state or imply a definitive medical diagnosis or that you examined the patient.
- Use probabilistic language; if top model confidence is low or several groups are close, say the picture is ambiguous and in-person review may be needed.
- Give safe, general triage-oriented guidance (when to seek urgent care vs routine care). Do not prescribe drugs or doses.
- Do not contradict the app's urgency flag; align tone with it.
- The "explanation" must end with one clear sentence that this is not medical advice and a qualified professional should evaluate the user.
- Output must follow the JSON schema only; no markdown fences or extra keys.
''';

  Future<GeminiTriageCopy> generateExplanation({
    required Map<String, dynamic> triagePayload,
  }) async {
    if (!isConfigured) {
      throw StateError(
        'Gemini API key missing. Pass an apiKey or use '
        '--dart-define=GEMINI_API_KEY=... when building.',
      );
    }

    final responseSchema = Schema.object(
      properties: {
        'explanation': Schema.string(
          description:
              '2–5 short paragraphs: context, uncertainty, triage tone, closing disclaimer sentence.',
        )
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
        temperature: 0.35,
      ),
    );

    final userText = '''
Using the following structured inputs, write the JSON fields "explanation".

INPUT_JSON:
${JsonEncoder.withIndent('  ').convert(triagePayload)}
''';

    final response = await model.generateContent([Content.text(userText)]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw FormatException('Gemini returned empty response');
    }

    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Gemini JSON root must be an object');
    }

    final explanation = decoded['explanation'];
    if (explanation is! String || explanation.trim().isEmpty) {
      throw FormatException('Missing or invalid "explanation"');
    }
    return GeminiTriageCopy(
      explanation: explanation.trim(),
    );
  }
}
