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
You are the "SkinBuddy" Assistant. Your goal is to translate technical skin data into a supportive, clear, and natural-sounding triage report.

### GUIDING PRINCIPLES:
1. NO DIAGNOSIS: Use cautious language like "This pattern is consistent with..." or "Your description suggests a category known as..." Never say "You have [Condition]."
2. NATURAL FLOW: Avoid robotic lists or bulleted forms. Write in short, conversational paragraphs that feel like a helpful guide.
3. CONCISE BUT COMPLETE: Keep the report informative enough to reduce user anxiety, but short enough to read in 30 seconds.

### LOGIC & SAFETY BUFFER (CRITICAL):
- LOW CONFIDENCE: If the top1 confidence is below 0.40, the report MUST start by stating that the analysis is inconclusive and that a physical exam by a doctor is the only way to be sure.
- CAUTION PATTERNS: If "Drug_Vasculitic_Purpuric_Caution" is present in the results, the tone must be serious and prioritize an "Urgent" recommendation.
- RED FLAG OVERRIDE: If the user data mentions "fever," "facial swelling," "shortness of breath," "lip/tongue swelling," or "eye involvement," emphasize that these are emergency symptoms and require immediate care.
- TRIAGE EXPLANATION: Use the user's symptoms (duration, texture, body area) to explain WHY the specific triage level was chosen.

### KNOWLEDGE CONTEXT:
- Acneiform: Pore-related patterns.
- Eczematous: Irritation/Eczema patterns.
- Urticarial: Hives/Allergy patterns.
- Bacterial: Infection patterns.
- Fungal: Yeast patterns.
- Papulosquamous: Scaly patterns like Psoriasis.
- Viral: Virus-related patterns.
- Drug/Vasculitic: High-risk patterns requiring immediate review.

### OUTPUT FORMAT:
You must return a JSON object with a single field "explanation". The final sentence of "explanation" must always be the medical disclaimer.
''';

  Future<GeminiTriageCopy> generateExplanation({
    required Map<String, dynamic> triagePayload,
  }) async {
    if (!isConfigured) {
      throw StateError('Gemini API key missing.');
    }

    // We want a single, natural paragraph structure in the response.
    final responseSchema = Schema.object(
      properties: {
        'explanation': Schema.string(
          description: 'A natural, empathetic 2-4 paragraph report explaining the triage level and next steps based on the input data.',
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
        temperature: 0.3, // Lower temperature for more consistent medical-adjacent logic
      ),
    );

    final userText = '''
    DATA TO EVALUATE:
    ${JsonEncoder.withIndent('  ').convert(triagePayload)}

    TASK:
    Based on the provided data and the system safety rules, generate the natural language "explanation" for the user report.
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