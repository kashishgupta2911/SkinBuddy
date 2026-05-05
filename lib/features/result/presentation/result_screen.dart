import 'dart:io';

import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.label,
    required this.confidence,
    required this.triage,
    required this.triageReason,
    required this.disclaimer,
  });

  final String imagePath;
  final String label;
  final double confidence;
  final String triage;
  final String triageReason;
  final String disclaimer;

  @override
  Widget build(BuildContext context) {
    final isUrgent = triage == 'urgent';
    final triageText = isUrgent ? 'URGENT' : 'NON-URGENT';
    final triageColor = isUrgent ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Triage Result')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(imagePath), fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text('Predicted class: $label', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Confidence: ${(confidence * 100).toStringAsFixed(2)}%'),
            const SizedBox(height: 8),
            Text(
              triageText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: triageColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Reason: $triageReason'),
            const SizedBox(height: 16),
            Text(
              disclaimer,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
