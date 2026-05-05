import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../analysis/presentation/analyzing_screen.dart';

const List<String> _bodyAreas = [
  'Head or Neck',
  'Arm',
  'Palm',
  'Back of Hand',
  'Torso (Front)',
  'Torso (Back)',
  'Genitalia or Groin',
  'Buttocks',
  'Leg',
  'Foot (Top/Side)',
  'Foot (Sole)',
  'Other',
];

const List<String> _durations = [
  'One day',
  'Less than one week',
  '1–4 weeks',
  '1–3 months',
  '3–12 months',
  'More than one year',
  'More than five years',
  'Since childhood',
  'Unknown',
];

const List<String> _conditionSymptoms = [
  'Bothersome appearance',
  'Bleeding',
  'Increasing size',
  'Darkening',
  'Itching',
  'Burning',
  'Pain',
  'None of these',
];

const List<String> _otherSymptoms = [
  'Fever',
  'Chills',
  'Fatigue',
  'Joint pain',
  'Mouth sores',
  'Shortness of breath',
  'None of these',
];

const List<String> _textures = [
  'Raised or bumpy',
  'Flat',
  'Rough or flaky',
  'Fluid filled',
  'Unspecified',
];

const List<String> _relatedCategories = [
  'Acne',
  'Growth or mole',
  'Hair loss',
  'Other hair problem',
  'Nail problem',
  'Pigmentary problem',
  'Rash',
  'Looks healthy',
  'Other',
];

class ContextScreen extends StatefulWidget {
  const ContextScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ContextScreen> createState() => _ContextScreenState();
}

class _ContextScreenState extends State<ContextScreen> {
  String? _selectedCategory;
  String? _selectedTexture;
  final Set<String> _selectedBodyAreas = {};
  final Set<String> _selectedConditionSymptoms = {};
  final Set<String> _selectedOtherSymptoms = {};
  String? _selectedDuration;
  bool _isUnder18 = false;

  @override
  void initState() {
    super.initState();
    _checkAgeRange();
  }

  Future<void> _checkAgeRange() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final ageRange =
          (snapshot.data()?['age_range'] as String? ?? '').trim().toLowerCase();

      final isMinor = ageRange == 'under 18' ||
          ageRange == '0–12' ||
          ageRange == '0-12' ||
          ageRange == '13–17' ||
          ageRange == '13-17';

      if (mounted && isMinor) {
        setState(() => _isUnder18 = true);
      }
    } catch (_) {}
  }

  void _handleContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          imagePath: widget.imagePath,
          contextData: {
            'related_category': _selectedCategory,
            'texture': _selectedTexture,
            'body_area': _selectedBodyAreas.toList(),
            'condition_symptoms': _selectedConditionSymptoms.toList(),
            'other_symptoms': _selectedOtherSymptoms.toList(),
            'duration': _selectedDuration,
          },
        ),
      ),
    );
  }

  void _handleSkip() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(imagePath: widget.imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    _buildPhotoPreview(),

                    if (_isUnder18) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildUnder18Disclaimer(),
                    ],

                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle('About the condition'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDropdownQuestion(
                      title: 'What type of skin issue does it seem like?',
                      hint: 'Select a category',
                      value: _selectedCategory,
                      options: _relatedCategories,
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDropdownQuestion(
                      title: 'What does the affected area look like?',
                      hint: 'Select texture',
                      value: _selectedTexture,
                      options: _textures,
                      onChanged: (v) => setState(() => _selectedTexture = v),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMultiSelectQuestion(
                      title: 'Where is the affected area?',
                      options: _bodyAreas,
                      selected: _selectedBodyAreas,
                    ),

                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionTitle('Symptoms & Duration'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMultiSelectQuestion(
                      title: 'Skin Symptoms',
                      subtitle: 'How the affected area looks or feels',
                      options: _conditionSymptoms,
                      selected: _selectedConditionSymptoms,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildMultiSelectQuestion(
                      title: 'General Symptoms',
                      subtitle: 'Symptoms affecting more than just skin',
                      options: _otherSymptoms,
                      selected: _selectedOtherSymptoms,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDropdownQuestion(
                      title: 'How long has this been present?',
                      hint: 'Select duration',
                      value: _selectedDuration,
                      options: _durations,
                      onChanged: (v) => setState(() => _selectedDuration = v),
                    ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
            'A little more context helps',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.iconBg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'Your captured photo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnder18Disclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.redChip,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.redText.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.redText,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: 'Age Notice: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        'This tool is currently designed for adult skin conditions (18+). '
                        'For children and teenagers, professional medical evaluation is recommended.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildDropdownQuestion({
    required String title,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.brownLight),
            color: AppColors.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.brownMedium,
              ),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectQuestion({
    required String title,
    String? subtitle,
    required List<String> options,
    required Set<String> selected,
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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selected.remove(option);
                  } else {
                    selected.add(option);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.brownLight,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.iconBg, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _handleSkip,
              child: const Text('Skip'),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: FilledButton(
              onPressed: _handleContinue,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
