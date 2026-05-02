import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../history/domain/triage_record.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.imagePath,
    required this.record,
  });

  final String imagePath;
  final TriageRecord record;

  String get _urgencyTag =>
      record.triageLevel.isNotEmpty
          ? record.triageLevel
          : 'No triage level';
  Color get _tagBg {
    switch (record.triageLevel.toLowerCase()) {
      case 'urgent':
        return AppColors.redChip;
      case 'expedite':
        return AppColors.yellowChip;
      case 'nonurgent':
      default:
        return AppColors.greenChip;
    }
  }
  Color get _tagText {
    switch (record.triageLevel.toLowerCase()) {
      case 'urgent':
        return AppColors.redText;
      case 'expedite':
        return AppColors.yellowText;
      case 'nonurgent':
      default:
        return AppColors.greenText;
    }
  }
  String get _urgencySubtext {
    switch (record.triageLevel.toLowerCase()) {
      case 'urgent':
        return 'Consult a professional';
      case 'expedite':
        return 'Monitor closely and consider medical advice';
      case 'nonurgent':
      default:
        return 'Self-care recommended';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _buildPhotoCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildUrgencyBadge(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDetectionCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildRecommendationsCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildSelfCareTipsLink(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildActionButtons(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDisclaimer(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.iconBg.withValues(alpha: 0.5),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.brownDark,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text(
            'Your Report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.iconBg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(imagePath),
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: _tagBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _urgencyTag,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _tagText,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _urgencySubtext,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What we detected',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            record.explanation,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.iconBg.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended next steps',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Text(
            record.nextSteps.isNotEmpty
                ? record.nextSteps
                : 'No recommendations available.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfCareTipsLink() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        'View Self-Care Tips',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.download_outlined,
            label: 'Save Report',
            onTap: () {},
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.disclaimerBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: const TextSpan(
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: 'This is not a diagnosis. ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            TextSpan(
              text:
                  'This report is a triage tool only. Always consult a qualified healthcare professional for medical advice and diagnosis.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.iconBg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.brownDark),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
