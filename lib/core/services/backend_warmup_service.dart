import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BackendWarmupService {
  static DateTime? _lastWake;

  static Future<void> warmup() async {

    // prevent spam requests
    if (_lastWake != null) {

      final diff =
          DateTime.now().difference(
            _lastWake!,
          );

      if (diff.inMinutes < 10) {
        debugPrint(
          'Skipping warmup (recently warmed)',
        );
        return;
      }
    }

    try {

      debugPrint(
        'Warming Render backend...',
      );

      final response = await http.get(
        Uri.parse(
          'https://skinbuddy.onrender.com/health',
        ),
      );

      debugPrint(
        'Render warmup status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        _lastWake = DateTime.now();

        debugPrint(
          'Render backend awake',
        );
      }

    } catch (e) {

      debugPrint(
        'Warmup failed: $e',
      );
    }
  }
}