// lib/presentation/auth/setup_profile/steps/step2_dob_gender_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/date_util.dart'; // Utility for date formatting
import '../../../../core/utils/validation_util.dart'; // Utility for form validation
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../../../shared/widgets/app_text_field.dart'; // Reusable text field widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step2DobGenderForm extends StatefulWidget {
  const Step2DobGenderForm({super.key});

  @override
  State<Step2DobGenderForm> createState() => _Step2DobGenderFormState();
}

class _Step2DobGenderFormState extends State<Step2DobGenderForm> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  late TextEditingController _dobController; // Controller for date of birth input

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing date of birth from ViewModel
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    _dobController = TextEditingController(
      text: vm.dateOfBirth == null ? "" : DateUtil.formatDDMMYYYY(vm.dateOfBirth!),
    );
  }

  @override
  void dispose() {
    // Dispose controller to free resources
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // List of gender options
    final genders = [
      {'label': 'Male', 'icon': Icons.male, 'value': 'male'},
      {'label': 'Female', 'icon': Icons.female, 'value': 'female'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary title using headlineLarge from AppTheme
            Text(
              "Your Birthday & Gender",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6), // Spacing between title and description
            // Secondary description using bodyLarge from AppTheme
            Text(
              "This helps us personalize your dating experience.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8), // Spacing between description and note
            // Italicized note for required fields using labelLarge from AppTheme
            Text(
              "Fields marked with * are required.",
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24), // Spacing before form fields
            // Date of birth input field with date picker
            GestureDetector(
              onTap: () async {
                FocusScope.of(context).unfocus(); // Hide keyboard
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
                  validator: (v) => ValidationUtil().validateBirthday(vm.dateOfBirth), // Validate birthday
                ),
              ),
            ),
            const SizedBox(height: 24), // Spacing before gender selection
            // Gender selection label
            Text(
              "Gender *",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4), // Spacing before gender chips
            // Horizontal scrollable gender selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: genders.map((g) {
                  final isSelected = vm.sex == g['value'];
                  final isMale = g['value'] == 'male';
                  final selectedColor = isMale ? Colors.blue : Colors.pinkAccent;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            g['icon'] as IconData,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 6), // Spacing between icon and label
                          Text(g['label'] as String),
                        ],
                      ),
                      selected: isSelected,
                      selectedColor: selectedColor, // Color based on gender
                      onSelected: (_) => setState(() => vm.sex = g['value'] as String),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28), // Spacing before button
            // Next button to proceed to the next step
            AppButton(
              text: "Next",
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  vm.nextStep(); // Move to next step
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
              textStyle: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}