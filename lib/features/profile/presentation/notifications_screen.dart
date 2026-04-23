import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _scanReminders = true;
  bool _resultsReady = true;
  bool _weeklyTips = false;
  bool _productUpdates = false;

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
                'Notifications',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel('Scan notifications'),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleCard(
                children: [
                  _ToggleRow(
                    title: 'Scan Reminders',
                    subtitle: 'Monthly check-in reminders',
                    value: _scanReminders,
                    onChanged: (v) => setState(() => _scanReminders = v),
                  ),
                  const Divider(color: AppColors.iconBg, height: 1, indent: 16, endIndent: 16),
                  _ToggleRow(
                    title: 'Results Ready',
                    subtitle: 'When your analysis is complete',
                    value: _resultsReady,
                    onChanged: (v) => setState(() => _resultsReady = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionLabel('General'),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleCard(
                children: [
                  _ToggleRow(
                    title: 'Weekly Tips',
                    subtitle: 'Skincare advice and articles',
                    value: _weeklyTips,
                    onChanged: (v) => setState(() => _weeklyTips = v),
                  ),
                  const Divider(color: AppColors.iconBg, height: 1, indent: 16, endIndent: 16),
                  _ToggleRow(
                    title: 'Product Updates',
                    subtitle: 'New features and improvements',
                    value: _productUpdates,
                    onChanged: (v) => setState(() => _productUpdates = v),
                  ),
                ],
              ),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildToggleCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.brownLight.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
