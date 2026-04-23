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
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _WavePainter())),
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
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.brownMedium.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 44,
            color: AppColors.brownMedium,
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
            color: AppColors.iconBg,
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
        color: const Color(0xFFF5DABB).withValues(alpha: 0.45),
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
                  TextSpan(text: ': This is a triage tool, not a\nmedical diagnosis.\n'),
                  TextSpan(
                    text: 'Always consult a healthcare\nprofessional for medical advice.',
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

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()
      ..color = const Color(0xFFF5DABB)
      ..style = PaintingStyle.fill;

    final waveY = h * 0.32;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, waveY)
      ..cubicTo(
        w * 0.25, waveY + 35,
        w * 0.50, waveY + 30,
        w * 0.70, waveY + 5,
      )
      ..cubicTo(
        w * 0.85, waveY - 12,
        w * 0.95, waveY + 5,
        w, waveY - 5,
      )
      ..lineTo(w, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
