import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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