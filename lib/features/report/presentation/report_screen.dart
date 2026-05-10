import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/inference_service.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/triage_report_view_data.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({
    super.key,
    required this.viewData,
  });

  final TriageReportViewData viewData;

  String get _urgencyTag {
    final level =
        viewData.triageLevel.trim().toLowerCase();

    switch (level) {
      case 'urgent':
        return 'Urgent';

      case 'expedite':
        return 'Expedite';

      case 'nonurgent':
      default:
        return 'Nonurgent';
    }
  }

  Color get _tagBg {
    final level =
        viewData.triageLevel.trim().toLowerCase();

    switch (level) {
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
    final level =
        viewData.triageLevel.trim().toLowerCase();

    switch (level) {
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
    final level =
        viewData.triageLevel.trim().toLowerCase();

    switch (level) {
      case 'urgent':
        return 'Consult a healthcare professional soon';

      case 'expedite':
        return 'Medical follow-up recommended';

      case 'nonurgent':
      default:
        return 'Self-care and monitoring recommended';
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
                    _buildContextCard(),
                    const SizedBox(height: AppSpacing.md),
                    _buildPredictionsCard(),
                    const SizedBox(height: AppSpacing.md),
                    if (viewData.geminiError != null &&
                        viewData.explanation.isEmpty)
                      _buildGeminiErrorBanner(),
                    if (viewData.geminiError != null &&
                        viewData.explanation.isEmpty)
                      const SizedBox(height: AppSpacing.md),
                    _buildExplanationCard(),
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
          File(viewData.imagePath),
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

  Widget _buildContextCard() {
    final d = viewData.contextData;
    final rows = <(String, String)>[
      ('Related category', _asText(d['related_category'])),
      ('Texture', _asText(d['texture'])),
      ('Body areas', _joinList(d['body_area'])),
      ('Skin symptoms', _joinList(d['condition_symptoms'])),
      ('General symptoms', _joinList(d['other_symptoms'])),
      ('Duration', _asText(d['duration'])),
    ];

    return _sectionCard(
      title: 'Your context',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            _contextRow(rows[i].$1, rows[i].$2),
          ],
        ],
      ),
    );
  }

  Widget _contextRow(String label, String value) {
    final display = value.isEmpty ? '—' : value;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 128,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            display,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPredictionsCard() {

    final groups = [...viewData.predictedGroups]
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    final topConfidence =
        groups.isEmpty
            ? 0.0
            : groups.first.confidence;

    final isLowConfidence =
        topConfidence < 0.40;

    return Column(
      children: [

        if (isLowConfidence) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.yellowChip,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Text(
              'Clinical review recommended. '
              'The model confidence is low, '
              'so results should not be treated '
              'as definitive.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.yellowText,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),
        ],

        _sectionCard(
          title: 'Model predictions',
          subtitle:
              'Probabilities from AI-assisted screening '
              '(not a medical diagnosis).',
          child: groups.isEmpty
              ? const Text(
                  'No prediction scores available.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                )
              : Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0;
                        i < groups.length;
                        i++) ...[

                      if (i > 0)
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),

                      _predictionRow(groups[i]),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _predictionRow(PredictedGroup g) {

    final confidence =
        g.confidence.clamp(0.0, 1.0);

    final pct =
        (confidence * 100)
            .toStringAsFixed(1);

    Color barColor;

    String confidenceLabel;

    if (confidence >= 0.60) {

      barColor =
          AppColors.confidenceHigh;

      confidenceLabel =
          'High confidence';

    } else if (confidence >= 0.40) {

      barColor =
          AppColors.confidenceModerate;

      confidenceLabel =
          'Moderate confidence';

    } else {

      barColor =
          AppColors.confidenceLow;

      confidenceLabel =
          'Low confidence';
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    g.group
                        .replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    confidenceLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w500,
                      color: barColor,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    FontWeight.w700,
                color: barColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 10,
            backgroundColor:
                AppColors.iconBg,
            valueColor:
                AlwaysStoppedAnimation(
              barColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeminiErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.yellowChip.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.yellowText.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.yellowText,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              viewData.geminiError ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationCard() {
    final text = viewData.explanation.trim();
    return _sectionCard(
      title: 'What this may mean',
      child: Text(
        text.isEmpty
            ? 'No AI-generated summary is available for this report.'
            : text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          child,
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

  static String _asText(Object? value) {
    if (value == null) return '';
    final s = '$value'.trim();
    return s;
  }

  static String _joinList(Object? value) {
    if (value is! List) return '';
    return value
        .map((e) => '$e'.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
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
