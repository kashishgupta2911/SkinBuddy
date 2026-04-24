import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../capture/application/capture_controller.dart';
import '../../result/presentation/result_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final CaptureController _controller = CaptureController();
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  XFile? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SkinBuddy Triage')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _selectedImage == null
                  ? const Center(child: Text('Capture or select a skin image'))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
              child: const Text('Use Camera'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed:
                  _loading ? null : () => _pickImage(ImageSource.gallery),
              child: const Text('Pick From Gallery'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: (_selectedImage == null || _loading)
                  ? null
                  : () => _analyze(_selectedImage!.path),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analyze'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final selected = await _picker.pickImage(source: source, imageQuality: 90);
    if (selected == null) {
      return;
    }
    setState(() => _selectedImage = selected);
  }

  Future<void> _analyze(String imagePath) async {
    setState(() => _loading = true);
    try {
      final result = await _controller.analyze(imagePath);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            imagePath: imagePath,
            label: result['label'] as String,
            confidence: result['confidence'] as double,
            triage: result['triage'].toString().split('.').last,
            triageReason: result['triageReason'] as String,
            disclaimer: result['disclaimer'] as String,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}
