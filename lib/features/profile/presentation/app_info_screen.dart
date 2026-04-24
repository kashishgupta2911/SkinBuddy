import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'App Information',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildVersionCard(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel('About SkinBuddy'),
              const SizedBox(height: AppSpacing.sm),
              _buildAboutCard(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel('Our Values'),
              const SizedBox(height: AppSpacing.sm),
              _buildValuesCard(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel('Credits'),
              const SizedBox(height: AppSpacing.sm),
              _buildCreditsCard(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Row(
          children: [
            Icon(Icons.chevron_left, color: AppColors.primary, size: 22),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            alignment: Alignment.center,
            child: const Text(
              'SB',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'SkinBuddy',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Version 1.0.0',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Build 2024.04.001',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.navUnselected,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text:
                  'SkinBuddy is a modern skin concern triage app designed for '
                  'everyday Canadians. We help you photograph skin concerns, '
                  'add lifestyle context, and receive urgency-level reports.\n\n',
            ),
            TextSpan(
              text: 'Important: ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text:
                  'SkinBuddy provides informational guidance only and does not '
                  'provide medical diagnoses. Always consult with a healthcare '
                  'professional for medical advice.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildValueItem(
            icon: Icons.favorite_outline,
            title: 'Trustworthy Care',
            subtitle:
                'Evidence-based guidance with a warm, approachable tone',
            showDivider: true,
          ),
          _buildValueItem(
            icon: Icons.groups_outlined,
            title: 'Inclusive',
            subtitle:
                'Supporting diverse skin tones and age groups',
            showDivider: true,
          ),
          _buildValueItem(
            icon: Icons.shield_outlined,
            title: 'Private',
            subtitle: 'Your data stays secure on your device',
            showDivider: true,
          ),
          _buildValueItem(
            icon: Icons.public,
            title: 'Made for Canadians',
            subtitle: 'Designed with Canadian healthcare in mind',
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconBg.withValues(alpha: 0.5),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
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
          ),
        ),
        if (showDivider)
          Divider(
            color: AppColors.brownLight.withValues(alpha: 0.3),
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Text(
            'Made with care by the SkinBuddy team',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            '\u00a9 2026 SkinBuddy Inc.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
