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
    final scores = output.first;
    int maxIndex = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[maxIndex]) {
        maxIndex = i;
      }
    }

    final confidence = _softmaxConfidence(scores, maxIndex);
    final label = maxIndex < _labels.length ? _labels[maxIndex] : 'unknown';
    return PredictionResult(label: label, confidence: confidence);
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

  double _softmaxConfidence(List<double> logits, int chosenIndex) {
    final maxLogit = logits.reduce(math.max);
    final expValues = logits.map((l) => math.exp(l - maxLogit)).toList();
    final denom = expValues.fold<double>(0, (sum, v) => sum + v);
    if (denom == 0) {
      return 0;
    }
    return expValues[chosenIndex] / denom;
  }
}
