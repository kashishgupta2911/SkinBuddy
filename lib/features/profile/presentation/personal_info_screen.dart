import 'package:flutter/material.dart';

import '../../../core/services/profile_store.dart';
import '../../../core/theme/app_theme.dart';

const List<String> _skinTypes = [
  'Normal',
  'Dry',
  'Oily',
  'Combination',
  'Sensitive',
];

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _store = ProfileStore.instance;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late DateTime _dateOfBirth;
  late String _skinType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _store.fullName);
    _emailController = TextEditingController(text: _store.email);
    _dateOfBirth = _store.dateOfBirth;
    _skinType = _store.skinType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _dateOfBirth = picked);
  }

  void _handleSave() {
    _store.fullName = _nameController.text;
    _store.email = _emailController.text;
    _store.dateOfBirth = _dateOfBirth;
    _store.skinType = _skinType;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String get _formattedDate =>
      '${_dateOfBirth.year}-${_dateOfBirth.month.toString().padLeft(2, '0')}-${_dateOfBirth.day.toString().padLeft(2, '0')}';

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
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildTextField(
                      label: 'Full Name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildDateField(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSkinTypeField(),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: _handleSave,
                      child: const Text('Save Changes'),
                    ),
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
            child: const Row(
              children: [
                Icon(
                  Icons.chevron_left,
                  color: AppColors.primary,
                  size: 22,
                ),
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.brownLight.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.brownLight.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          onTap: _handlePickDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.brownLight.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formattedDate,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.brownMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skin Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.brownLight.withValues(alpha: 0.5),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _skinType,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.brownMedium,
              ),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              items: _skinTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _skinType = v);
              },
            ),
          ),
        ),
      ],
    );
  }
}
