import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../context/presentation/context_screen.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.imagePath});

  final String imagePath;

  void _handleRetakePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (image == null) return;
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ContextScreen(imagePath: image.path),
      ),
    );
  }

  void _handleChooseGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ContextScreen(imagePath: image.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxl),
                      _buildWarningIcon(),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'Unable to Analyze Image',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'We couldn\'t analyze this image. For best results,\nmake sure your photo is:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildTipCard(
                        'Clear and in focus — Avoid blurry images',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTipCard(
                        'Well-lit — Use natural lighting when possible',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTipCard(
                        'Showing skin clearly — Avoid objects, text, or screenshots',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => _handleRetakePhoto(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Take Another Photo'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => _handleChooseGallery(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.iconBg.withValues(alpha: 0.4),
                  side: BorderSide.none,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Choose from Gallery'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'If you continue to experience issues, please contact support',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.iconBg.withValues(alpha: 0.5),
      ),
      child: const Icon(
        Icons.error_outline,
        size: 36,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildTipCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.iconBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

