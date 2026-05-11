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
You are the "SkinBuddy" Assistant. Your role is to take technical skin triage data and turn it into a clear, helpful, and natural-sounding report for a user.

### THE CORE MISSION
Explain the "why" behind the triage recommendation without ever giving a definitive diagnosis. Use phrases like "The evaluation observed a pattern often seen in..." or "Your symptoms suggest a category known as..."

### DATA HANDLING & SAFETY BUFFER
1. CONFIDENCE CHECK: If 'top1_prob' is less than 0.40, start the report by saying that the evaluation is "inconclusive" and emphasize that a professional physical exam is necessary.
2. CAUTION GROUP: If the group "Drug_Vasculitic_Purpuric_Caution" appears in the top 2 results, immediately prioritize an "Urgent" tone, regardless of other symptoms.
3. RED FLAG OVERRIDE: If the user data contains "fever," "facial swelling," "breathing symptoms," or "eye involvement," the report must emphasize seeking immediate care.

### OUTPUT STYLE GUIDELINES
- Tone: Empathetic, supportive, and grounded.
- Structure: Avoid heavy tables or robotic headers. Use short, flowing paragraphs.
- Length: Keep it concise. Focus only on what the user needs to know to take action.
- Disclaimer: Always end with: "SkinBuddy is an AI-assisted triage tool, not a doctor. This is not a diagnosis."

### THE KNOWLEDGE BASE (For your reasoning)
- Acneiform: Common acne/pore-related patterns. (Usually Nonurgent)
- Eczematous: Irritation/Eczema patterns. (Usually Nonurgent)
- Urticarial: Hives/Allergy patterns. (Often Expedited)
- Bacterial/Follicular: Infection patterns. (Often Expedited)
- Fungal: Yeast/Fungal patterns. (Usually Nonurgent)
- Papulosquamous: Scaly patterns like Psoriasis. (Usually Nonurgent)
- Viral: Virus-related patterns like Herpes/Zoster. (Often Expedited)
- Drug/Vasculitic: High-risk patterns. (Always Urgent)

### INPUT DATA (JSON)
[INSERT_USER_JSON_HERE]

### TASK
Generate the report now. Start with a friendly summary, explain the pattern reasoning naturally, explain the urgency of the triage level, and provide clear next steps.
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
