import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../analysis/presentation/analyzing_screen.dart';

const List<String> _stressEmojis = ['😔', '🙂', '😐', '😟', '😢'];
const List<String> _sleepOptions = ['Poor', 'Fair', 'Good'];
const List<String> _durationOptions = [
  'Less than a week',
  '1-2 weeks',
  '2-4 weeks',
  '1-3 months',
  'More than 3 months',
];
const List<String> _bodyAreas = [
  'Face',
  'Neck',
  'Chest',
  'Arms',
  'Hands',
  'Legs',
  'Back',
  'Other',
];

class ContextScreen extends StatefulWidget {
  const ContextScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ContextScreen> createState() => _ContextScreenState();
}

class _ContextScreenState extends State<ContextScreen> {
  int? _selectedStress;
  int? _selectedSleep;
  bool? _changedProducts;
  String? _selectedDuration;
  final Set<String> _selectedBodyAreas = {};

  void _handleContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          imagePath: widget.imagePath,
          contextData: {
            'stress': _selectedStress,
            'sleep': _selectedSleep != null ? _sleepOptions[_selectedSleep!] : null,
            'changedProducts': _changedProducts,
            'duration': _selectedDuration,
            'bodyAreas': _selectedBodyAreas.toList(),
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
                    const SizedBox(height: AppSpacing.md),
                    _buildPhotoPreview(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStressQuestion(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSleepQuestion(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSkincareQuestion(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDurationQuestion(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBodyAreaQuestion(),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.iconBg,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
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
    );
  }

  Widget _buildStressQuestion() {
    return _QuestionSection(
      title: 'How stressed have you been lately?',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_stressEmojis.length, (i) {
          final isSelected = _selectedStress == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedStress = i),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _stressEmojis[i],
                style: const TextStyle(fontSize: 26),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSleepQuestion() {
    return _QuestionSection(
      title: "How's your sleep quality?",
      child: Row(
        children: List.generate(_sleepOptions.length, (i) {
          final isSelected = _selectedSleep == i;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : AppSpacing.sm,
              ),
              child: _ChoiceChipButton(
                label: _sleepOptions[i],
                isSelected: isSelected,
                onTap: () => setState(() => _selectedSleep = i),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSkincareQuestion() {
    return _QuestionSection(
      title: 'Have you recently changed any skincare products?',
      child: Row(
        children: [
          Expanded(
            child: _ChoiceChipButton(
              label: 'No',
              isSelected: _changedProducts == false,
              onTap: () => setState(() => _changedProducts = false),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _ChoiceChipButton(
              label: 'Yes',
              isSelected: _changedProducts == true,
              onTap: () => setState(() => _changedProducts = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationQuestion() {
    return _QuestionSection(
      title: 'How long has this concern been present?',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.brownLight),
          color: AppColors.surface,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedDuration,
            isExpanded: true,
            hint: const Text(
              'Select duration',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.brownMedium,
            ),
            items: _durationOptions
                .map(
                  (d) => DropdownMenuItem(value: d, child: Text(d)),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedDuration = v),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyAreaQuestion() {
    return _QuestionSection(
      title: 'Which area of your body?',
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: _bodyAreas.map((area) {
          final isSelected = _selectedBodyAreas.contains(area);
          return _ChoiceChipButton(
            label: area,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedBodyAreas.remove(area);
                } else {
                  _selectedBodyAreas.add(area);
                }
              });
            },
            compact: true,
          );
        }).toList(),
      ),
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

class _QuestionSection extends StatelessWidget {
  const _QuestionSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        child,
      ],
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 12,
          vertical: compact ? 10 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.brownLight,
          ),
        ),
        alignment: compact ? null : Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
