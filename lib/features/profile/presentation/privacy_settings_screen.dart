import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _shareAnonymousData = true;
  bool _localStorageOnly = true;
  bool _biometricLock = false;

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
                'Privacy Settings',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildPrivacyNotice(),
              const SizedBox(height: AppSpacing.xl),
              _buildSectionLabel('Data Usage'),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleCard(
                children: [
                  _ToggleRow(
                    title: 'Share Anonymous Data',
                    subtitle:
                        'Help improve SkinBuddy by sharing anonymized usage data',
                    value: _shareAnonymousData,
                    onChanged: (v) =>
                        setState(() => _shareAnonymousData = v),
                  ),
                  const Divider(
                    color: AppColors.iconBg,
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _ToggleRow(
                    title: 'Local Storage Only',
                    subtitle: 'Store all data on this device only',
                    value: _localStorageOnly,
                    onChanged: (v) =>
                        setState(() => _localStorageOnly = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionLabel('Security'),
              const SizedBox(height: AppSpacing.sm),
              _buildToggleCard(
                children: [
                  _ToggleRow(
                    title: 'Biometric Lock',
                    subtitle:
                        'Require Face ID or Touch ID to open app',
                    value: _biometricLock,
                    onChanged: (v) =>
                        setState(() => _biometricLock = v),
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

  Widget _buildPrivacyNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'SkinBuddy is committed to protecting your privacy. Your photos and '
        'personal health information are stored securely on your device and '
        'never shared without your explicit consent.',
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
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
