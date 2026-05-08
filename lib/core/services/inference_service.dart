import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  const PredictionResult({required this.label, required this.confidence});

  final String label;
  final double confidence;
}

/// One model hypothesis with softmax probability (used for reports and Gemini).
class PredictedGroup {
  const PredictedGroup({required this.group, required this.confidence});

  final String group;
  final double confidence;

  Map<String, dynamic> toFirestoreMap() => {
        'group': group,
        'confidence': confidence,
      };
}

class InferenceService {
  InferenceService({
    this.modelAssetPath = 'assets/models/model.tflite',
    this.labelsAssetPath = 'assets/models/labels.txt',
    this.inputSize = 224,
  });

  final String modelAssetPath;
  final String labelsAssetPath;
  final int inputSize;

  Interpreter? _interpreter;
  List<String> _labels = const <String>[];

  Future<void> initialize() async {
    _interpreter ??= await Interpreter.fromAsset(modelAssetPath);
    _labels = await _loadLabels(labelsAssetPath);
  }

  Future<PredictionResult> predict(String imagePath) async {
    final groups = await predictGroups(imagePath, limit: 1);
    if (groups.isEmpty) {
      return const PredictionResult(label: 'unknown', confidence: 0);
    }
    final top = groups.first;
    return PredictionResult(label: top.group, confidence: top.confidence);
  }

  /// Ranked list of `{group, confidence}` (softmax), longest-first by confidence.
  Future<List<PredictedGroup>> predictGroups(
    String imagePath, {
    int limit = 10,
  }) async {
    await initialize();

    final Uint8List bytes = await File(imagePath).readAsBytes();
    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw Exception('Unable to decode image at path: $imagePath');
    }

    final img.Image resized = img.copyResize(
      decoded,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.average,
    );

    final input = _buildInputTensor(resized);
    final output = List<List<double>>.generate(
      1,
      (_) => List<double>.filled(_labels.length, 0),
    );

    _interpreter!.run(input, output);
    final raw = output.first;
    final classCount = _labels.length;
    if (classCount == 0) {
      return const <PredictedGroup>[];
    }

    final logits = raw.sublist(0, classCount);
    final probs = _softmaxProbs(logits);

    final entries = List<PredictedGroup>.generate(
      classCount,
      (i) => PredictedGroup(
        group: _labels[i],
        confidence: probs[i],
      ),
    );
    entries.sort((a, b) => b.confidence.compareTo(a.confidence));

    final cap = math.min(limit, entries.length);
    return entries.sublist(0, cap);
  }

  Future<List<String>> _loadLabels(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    return raw
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  List<List<List<List<double>>>> _buildInputTensor(img.Image resized) {
    return <List<List<List<double>>>>[
      List<List<List<double>>>.generate(inputSize, (y) {
        return List<List<double>>.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          final r = pixel.r / 255.0;
          final g = pixel.g / 255.0;
          final b = pixel.b / 255.0;
          return <double>[r, g, b];
        });
      }),
    ];
  }

  List<double> _softmaxProbs(List<double> logits) {
    if (logits.isEmpty) {
      return const <double>[];
    }
    final maxLogit = logits.reduce(math.max);
    final expValues = logits.map((l) => math.exp(l - maxLogit)).toList();
    final denom = expValues.fold<double>(0, (sum, v) => sum + v);
    if (denom == 0) {
      return List<double>.filled(logits.length, 0);
    }
    return expValues.map((v) => v / denom).toList(growable: false);
  }
}
