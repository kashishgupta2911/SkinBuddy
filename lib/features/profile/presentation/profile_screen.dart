import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/presentation/login_screen.dart';
import 'app_info_screen.dart';
import 'delete_data_screen.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'privacy_settings_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildProfileCard(),
              const SizedBox(height: AppSpacing.xl),
              _buildSection(
                title: 'Account',
                items: [
                  _MenuItem(
                    icon: Icons.person_outline,
                    label: 'Personal Information',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PersonalInfoScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'Privacy and Data',
                items: [
                  _MenuItem(
                    icon: Icons.lock_outline,
                    label: 'Privacy Settings',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.delete_outline,
                    label: 'Delete My Data',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DeleteDataScreen(),
                      ),
                    ),
                    isDestructive: true,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'About',
                items: [
                  _MenuItem(
                    icon: Icons.info_outline,
                    label: 'App Information',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AppInfoScreen(),
                      ),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'Session',
                items: [
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Log Out',
                    isDestructive: true,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();

                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                              (_) => false,
                        );
                      }
                    },
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

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.iconBg,
                  border: Border.all(
                    color: AppColors.brownLight,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.brownMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alice Williams',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'alicewilliams@gmail.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.iconBg, height: 1),
          const SizedBox(height: AppSpacing.md),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '4', label: 'Total Scans'),
              _StatItem(value: '2', label: 'This Month'),
              _StatusItem(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
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
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.iconBg.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  if (i > 0)
                    const Divider(
                      color: AppColors.iconBg,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                  _buildMenuItem(item),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: item.isDestructive
                  ? Colors.redAccent
                  : AppColors.brownMedium,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: item.isDestructive
                      ? Colors.redAccent
                      : AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.navUnselected,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle, size: 22, color: AppColors.greenText),
        SizedBox(height: 4),
        Text(
          'All Clear',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
