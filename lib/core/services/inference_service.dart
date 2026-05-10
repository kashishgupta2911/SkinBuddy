import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PredictedGroup {
  final String group;
  final double confidence;

  const PredictedGroup({
    required this.group,
    required this.confidence,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'name': group,
      'confidence': confidence,
    };
  }

  factory PredictedGroup.fromJson(
    Map<String, dynamic> json,
  ) {
    return PredictedGroup(
      group: json['name'] ?? 'unknown',
      confidence:
          (json['confidence'] as num?)
              ?.toDouble() ??
          0.0,
    );
  }
}

class PredictionResult {
  final String label;
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.confidence,
  });
}

class InferenceService {
  final String baseUrl =
      'https://skinbuddy.onrender.com';

  Future<Map<String, dynamic>> analyzeImage({
    required String imagePath,
    required Map<String, dynamic> metadata,
  }) async {

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/predict'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ),
    );

    request.fields['metadata'] =
        jsonEncode(metadata);

    final response = await request.send();

    final body =
    await response.stream.bytesToString();

    return jsonDecode(body);
  }
}