import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/triage_record.dart';

class _ScanEntry {
  const _ScanEntry({
    required this.location,
    required this.dateTime,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.predictedGroup,
    required this.imageUrl,
  });

  final String location;
  final String dateTime;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
  final String predictedGroup;
  final String imageUrl;

  factory _ScanEntry.fromRecord(TriageRecord record) {
    final triageText = record.triageLevel.trim();

    final resolvedTriage =
    triageText.isNotEmpty ? _formatTriageLevel(triageText) : 'No triage level';

    final triageKey = resolvedTriage.toLowerCase();

    Color tagColor;
    Color tagTextColor;

    switch (triageKey) {
      case 'urgent':
        tagColor = AppColors.redChip;
        tagTextColor = AppColors.redText;
        break;

      case 'expedited':
        tagColor = AppColors.yellowChip;
        tagTextColor = AppColors.yellowText;
        break;

      case 'nonurgent':
      default:
        tagColor = AppColors.greenChip;
        tagTextColor = AppColors.greenText;
        break;
    }

    return _ScanEntry(
      location: record.bodyPart,
      dateTime: _formatTimestamp(record.timestamp),
      tag: resolvedTriage,
      tagColor: tagColor,
      tagTextColor: tagTextColor,
      predictedGroup: record.predictedGroup,
      imageUrl: record.imgUrl,
    );
  }

  static String _formatTriageLevel(String value) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) return 'No triage level';

    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  static String _formatTimestamp(DateTime timestamp) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final month = months[timestamp.month - 1];
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minutes = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';

    return '$month ${timestamp.day}, ${timestamp.year} · $hour:$minutes $period';
  }
}

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
    return StreamBuilder<List<TriageRecord>>(
      stream: _historyStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildMessageCard(
            icon: Icons.error_outline,
            title: 'Unable to load history',
            message: 'Please try again in a moment.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entries = (snapshot.data ?? const <TriageRecord>[])
            .map(_ScanEntry.fromRecord)
            .toList(growable: false);

        if (entries.isEmpty) {
          return _buildMessageCard(
            icon: Icons.access_time_rounded,
            title: 'No scan history yet',
            message: 'Your completed scans will appear here over time.',
          );
        }

        return Column(
          children: List.generate(entries.length, (i) {
            return _TimelineItem(
              entry: entries[i],
              isFirst: i == 0,
              isLast: i == entries.length - 1,
            );
          }),
        );
      },
    );
  }

  Stream<List<TriageRecord>> _historyStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <TriageRecord>[]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs
              .map(TriageRecord.fromFirestore)
              .toList(growable: false);
          records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return records;
        });
  }

  Widget _buildMessageCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.navUnselected, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: entry.imageUrl.isNotEmpty
                ? Image.network(
              entry.imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 52,
                  height: 52,
                  color: AppColors.iconBg,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            )
                : Container(
              width: 52,
              height: 52,
              color: AppColors.iconBg,
              child: const Icon(Icons.image),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                const SizedBox(height: 4),
                Text(
                  'Likely: ${entry.predictedGroup}',
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
