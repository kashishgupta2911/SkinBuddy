import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../history/domain/triage_record.dart';
import '../../scan/presentation/scan_screen.dart';
import 'quick_tip_detail_screen.dart';

class _ScanEntry {
  const _ScanEntry({
    required this.location,
    required this.date,
    required this.tag,
    required this.tagColor,
    required this.tagTextColor,
    required this.imageUrl,
  });

  final String location;
  final String date;
  final String tag;
  final Color tagColor;
  final Color tagTextColor;
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

      case 'expedite':
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
      date: _formatTimestamp(record.timestamp),
      tag: resolvedTriage,
      tagColor: tagColor,
      tagTextColor: tagTextColor,
      imageUrl: record.imgUrl,
    );
  }

  static String _formatTriageLevel(String value) {
    final cleaned = value.trim().toLowerCase();

    if (cleaned.isEmpty) return 'No triage level';

    switch (cleaned) {
      case 'expedited':
        return 'Expedite';

      case 'nonurgent':
        return 'Nonurgent';

      case 'urgent':
        return 'Urgent';

      default:
        return cleaned[0].toUpperCase() + cleaned.substring(1);
    }
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
    return '$month ${timestamp.day}, ${timestamp.year}';
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleNewScan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
  }

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
              _buildGreeting(),
              const SizedBox(height: AppSpacing.lg),
              _buildNewScanButton(context),
              const SizedBox(height: AppSpacing.xl + 8),
              _buildRecentScans(),
              const SizedBox(height: AppSpacing.xl + 8),
              _buildQuickTips(context),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hey!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'How can we help you today?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        String firstName = 'there';

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          firstName =
              (data?['first_name'] as String? ?? '').trim();

          if (firstName.isEmpty) {
            firstName = 'there';
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, $firstName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'How can we help you today?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleNewScan(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 52),
        decoration: BoxDecoration(
          color: AppColors.brownMedium,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26),
            SizedBox(width: AppSpacing.sm),
            Text(
              'New Scan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        StreamBuilder<List<TriageRecord>>(
          stream: _recentScansStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text(
                'No recent scans yet',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final entries = (snapshot.data ?? const <TriageRecord>[])
                .take(3)
                .map(_ScanEntry.fromRecord)
                .toList(growable: false);

            if (entries.isEmpty) {
              return const Text(
                'No recent scans yet',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              );
            }

            return Column(
              children: List.generate(entries.length, (index) {
                final entry = entries[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == entries.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  child: _buildScanCard(
                    location: entry.location,
                    date: entry.date,
                    tag: entry.tag,
                    tagColor: entry.tagColor,
                    tagTextColor: entry.tagTextColor,
                    imageUrl: entry.imageUrl,
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Stream<List<TriageRecord>> _recentScansStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Stream.value(const <TriageRecord>[]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('triage_records')
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map(TriageRecord.fromFirestore)
          .toList(growable: false);

      records.sort(
            (a, b) => b.timestamp.compareTo(a.timestamp),
      );

      return records;
    });
  }

  Widget _buildScanCard({
    required String location,
    required String date,
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 48,
                  height: 48,
                  color: AppColors.iconBg,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            )
                : Container(
              width: 48,
              height: 48,
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
                  location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tagTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTipCard(
                context: context,
                icon: Icons.wb_sunny_outlined,
                label: 'UV Protection',
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildTipCard(
                context: context,
                icon: Icons.water_drop_outlined,
                label: 'Hydration',
                iconColor: AppColors.greenText,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildTipCard(
                context: context,
                icon: Icons.favorite_outline,
                label: 'Self-Care',
                iconColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => QuickTipDetailScreen(categoryKey: label),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.tipCardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
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
