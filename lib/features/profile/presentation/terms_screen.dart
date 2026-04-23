import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class _TermsSection {
  const _TermsSection({
    required this.title,
    this.body,
    this.richBody,
    this.bullets,
  });

  final String title;
  final String? body;
  final List<InlineSpan>? richBody;
  final List<String>? bullets;
}

final _sections = <_TermsSection>[
  const _TermsSection(
    title: '1. Acceptance of Terms',
    body:
        'By accessing and using SkinBuddy, you accept and agree to be bound by '
        'the terms and provision of this agreement. If you do not agree to '
        'these terms, please do not use this application.',
  ),
  _TermsSection(
    title: '2. Medical Disclaimer',
    richBody: [
      const TextSpan(
        text:
            'SkinBuddy is an informational tool designed to help users triage '
            'skin concerns. It is ',
      ),
      const TextSpan(
        text: 'NOT a substitute for professional medical advice, diagnosis, '
            'or treatment',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      const TextSpan(
        text:
            '.\n\nAlways seek the advice of your physician or other qualified '
            'health provider with any questions you may have regarding a '
            'medical condition. Never disregard professional medical advice or '
            'delay in seeking it because of something you have read or seen on '
            'SkinBuddy.',
      ),
    ],
  ),
  const _TermsSection(
    title: '3. User Responsibilities',
    body: 'You agree to:',
    bullets: [
      'Provide accurate and complete information when using the app',
      'Use the app only for lawful purposes',
      "Not attempt to reverse engineer or compromise the app's security",
      'Maintain the confidentiality of your account',
    ],
  ),
  const _TermsSection(
    title: '4. Privacy and Data',
    body:
        'Your privacy is important to us. We collect, use, and protect your '
        'personal information as described in our Privacy Policy. By using '
        'SkinBuddy, you consent to our data practices as outlined in the '
        'Privacy Policy.',
  ),
  const _TermsSection(
    title: '5. Intellectual Property',
    body:
        'All content, features, and functionality of SkinBuddy are owned by '
        'SkinBuddy Inc. and are protected by international copyright, '
        'trademark, and other intellectual property laws.',
  ),
  const _TermsSection(
    title: '6. Limitation of Liability',
    body:
        'SkinBuddy Inc. shall not be liable for any indirect, incidental, '
        'special, consequential, or punitive damages resulting from your use '
        'or inability to use the application.',
  ),
  const _TermsSection(
    title: '7. Changes to Terms',
    body:
        'We reserve the right to modify these terms at any time. We will '
        'notify users of any material changes via the app. Continued use of '
        'SkinBuddy after changes constitutes acceptance of the new terms.',
  ),
  const _TermsSection(
    title: '8. Contact Information',
    body: 'If you have questions about these Terms of Service, please '
        'contact us at:',
  ),
];

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                'Terms of Service',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Last updated: April 17, 2026',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...List.generate(_sections.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildSectionCard(_sections[i], isLast: i == _sections.length - 1),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
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

  Widget _buildSectionCard(_TermsSection section, {required bool isLast}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tipCardBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (section.richBody != null)
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
                children: section.richBody,
              ),
            )
          else if (section.body != null)
            Text(
              section.body!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          if (section.bullets != null) ...[
            const SizedBox(height: AppSpacing.sm),
            ...section.bullets!.map((bullet) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.brownMedium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        bullet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (isLast) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'legal@skinbuddy.com',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
