// lib/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/validation_util.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../setup_profile_viewmodel.dart';

// Form for collecting user's date of birth and gender during profile setup.
class Step2DobGenderForm extends StatefulWidget {
  const Step2DobGenderForm({super.key});

  @override
  State<Step2DobGenderForm> createState() => _Step2DobGenderFormState();
}

class _Step2DobGenderFormState extends State<Step2DobGenderForm> {
  // Key for form validation.
  final _formKey = GlobalKey<FormState>();

  // Controller for date of birth input field.
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing date from ViewModel
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _dobController = TextEditingController(
      text: vm.dateOfBirth == null ? "" : DateUtil.formatDDMMYYYY(vm.dateOfBirth!),
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define gender options with appropriate icons and colors
    final genders = [
      {
        'label': 'Male',
        'icon': Icons.male,
        'value': 'male',
        'color': Colors.blue
      },
      {
        'label': 'Female',
        'icon': Icons.female,
        'value': 'female',
        'color': Colors.pinkAccent
      },
      {
        'label': 'Non-binary',
        'icon': Icons.people_outline,
        'value': 'non-binary',
        'color': Colors.purpleAccent
      },
      {
        'label': 'Prefer not to say',
        'icon': Icons.help_outline,
        'value': 'prefer_not_to_say',
        'color': Colors.grey.shade700
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Text(
              "Your Birthday & Gender",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "This helps us personalize your dating experience.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Fields marked with * are required.",
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 24),

            // Date of birth picker
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus();
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: vm.dateOfBirth ?? DateTime(now.year - 20),
                  firstDate: DateTime(now.year - 120),
                  lastDate: DateTime(now.year - 18),
                );
                if (picked != null) {
                  setState(() {
                    vm.dateOfBirth = picked;
                    _dobController.text = DateUtil.formatDDMMYYYY(picked);
                  });
                }
              },
              child: AbsorbPointer(
                child: AppTextField(
                  labelText: "Birthday *",
                  prefixIcon: Icons.cake_rounded,
                  prefixIconColor: theme.colorScheme.primary,
                  controller: _dobController,
                  validator: (v) => ValidationUtil().validateBirthday(vm.dateOfBirth),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Gender selection section
            Text(
              "Gender *",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Gender chip options with horizontal scrolling
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genders.map((gender) {
                  final isSelected = vm.sex == gender['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            gender['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(gender['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: gender['color'] as Color,
                      onSelected: (_) => setState(() => vm.sex = gender['value'] as String),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Next button
            AppButton(
              text: "Next",
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  // Ensure gender is selected
                  if (vm.sex == null || vm.sex!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please select your gender")),
                    );
                    return;
                  }
                  vm.nextStep();
                }
              },
              width: double.infinity,
              height: 52,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}