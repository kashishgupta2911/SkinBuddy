import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class _ScanEntry {
  const _ScanEntry({
    required this.location,
    required this.dateTime,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
  });

  final String location;
  final String dateTime;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
}

const _entries = <_ScanEntry>[
  _ScanEntry(
    location: 'Left cheek',
    dateTime: 'April 10, 2026 · 2:30 PM',
    tag: 'Low urgency',
    tagColor: AppColors.greenChip,
    tagTextColor: AppColors.greenText,
  ),
  _ScanEntry(
    location: 'Forearm',
    dateTime: 'April 5, 2026 · 10:15 AM',
    tag: 'Monitor closely',
    tagColor: AppColors.orangeChip,
    tagTextColor: AppColors.orangeText,
  ),
  _ScanEntry(
    location: 'Right hand',
    dateTime: 'March 28, 2026 · 4:45 PM',
    tag: 'Low urgency',
    tagColor: AppColors.greenChip,
    tagTextColor: AppColors.greenText,
  ),
  _ScanEntry(
    location: 'Neck',
    dateTime: 'March 15, 2026 · 11:20 AM',
    tag: 'Low urgency',
    tagColor: AppColors.greenChip,
    tagTextColor: AppColors.greenText,
  ),
];

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Scan History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Track your skin health over time',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildTimeline(),
              const SizedBox(height: AppSpacing.lg),
              _buildInfoCard(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: List.generate(_entries.length, (i) {
        return _TimelineItem(
          entry: _entries[i],
          isFirst: i == 0,
          isLast: i == _entries.length - 1,
        );
      }),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'Track Changes Over Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Regular scans help you monitor changes and identify patterns in '
            'your skin health. Consider scanning every few weeks for best results.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final _ScanEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          if (!isFirst)
            Expanded(
              child: Container(
                width: 2,
                color: AppColors.brownLight.withValues(alpha: 0.4),
              ),
            ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: AppColors.brownLight.withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.location,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.dateTime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: entry.tagColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: entry.tagTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.navUnselected,
            size: 22,
          ),
        ],
      ),
    );
  }
}
