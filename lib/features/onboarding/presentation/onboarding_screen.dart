import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _handleGetStarted(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBD1),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/onboarding/wave.png',
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          _buildLogo(),
                          const SizedBox(height: AppSpacing.xxl + 24),
                          _buildFeatureItem(
                            icon: Icons.camera_alt_rounded,
                            title: 'Snap a photo',
                            subtitle:
                                'Take a clear picture of your skin concern',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildFeatureItem(
                            icon: Icons.chat_bubble_rounded,
                            title: 'Add context',
                            subtitle:
                                'Share lifestyle details to help us understand',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildFeatureItem(
                            icon: Icons.menu_book_rounded,
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
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/onboarding/heart.svg',
            width: 74,
            height: 74,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'SkinBuddy',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.brownDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Your skin, understood',
          style: TextStyle(
            fontSize: 17,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8F3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
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
        color: const Color(0xFFE8D5B8).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: 'Important',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                      text:
                          ': This is a triage tool, not a\nmedical diagnosis.\n'),
                  TextSpan(
                    text:
                        'Always consult a healthcare\nprofessional for medical advice.',
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
