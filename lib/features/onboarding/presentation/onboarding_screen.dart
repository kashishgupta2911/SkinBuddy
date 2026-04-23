import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../shell/app_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _handleGetStarted(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
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
                      const SizedBox(height: AppSpacing.xl),
                      _buildLogo(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildFeatureItem(
                        icon: Icons.camera_alt_outlined,
                        title: 'Snap a photo',
                        subtitle: 'Take a clear picture of your skin concern',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFeatureItem(
                        icon: Icons.chat_bubble_outline,
                        title: 'Add context',
                        subtitle:
                            'Share lifestyle details to help us understand',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFeatureItem(
                        icon: Icons.shield_outlined,
                        title: 'Get guidance',
                        subtitle:
                            'Receive an urgency assessment and next steps',
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _buildDisclaimer(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => _handleGetStarted(context),
                child: const Text('Get Started'),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.brownMedium.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 40,
            color: AppColors.brownMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'SkinBuddy',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Your skin, understood',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.brownMedium, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.disclaimerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: 'Important: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'This is a triage tool, not a medical diagnosis. Always consult a healthcare professional for medical advice.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
