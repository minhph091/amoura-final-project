// lib/presentation/auth/setup_profile/steps/step1_name_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validation_util.dart'; // Utility for form validation
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../../../shared/widgets/app_text_field.dart'; // Reusable text field widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step1NameForm extends StatefulWidget {
  const Step1NameForm({super.key});

  @override
  State<Step1NameForm> createState() => _Step1NameFormState();
}

class _Step1NameFormState extends State<Step1NameForm> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  late TextEditingController _firstNameCtrl; // Controller for first name input
  late TextEditingController _lastNameCtrl; // Controller for last name input

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values from ViewModel
    final vm = context.read<SetupProfileViewModel>();
    _firstNameCtrl = TextEditingController(text: vm.firstName ?? "");
    _lastNameCtrl = TextEditingController(text: vm.lastName ?? "");
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary title using headlineLarge from AppTheme
            Text(
              "Your Name",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6), // Spacing between title and description
            // Secondary description using bodyLarge from AppTheme
            Text(
              "This name will be visible to everyone.",
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
            // First name input field
            AppTextField(
              controller: _firstNameCtrl,
              labelText: "First Name *",
              prefixIcon: Icons.person,
              prefixIconColor: colorScheme.primary,
              maxLength: 50,
              validator: ValidationUtil().validateFirstName, // Validate first name
              onSaved: (v) => vm.firstName = v?.trim(), // Save trimmed value to ViewModel
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 18), // Spacing between fields
            // Last name input field
            AppTextField(
              controller: _lastNameCtrl,
              labelText: "Last Name *",
              prefixIcon: Icons.badge,
              prefixIconColor: colorScheme.primary,
              maxLength: 50,
              validator: ValidationUtil().validateLastName, // Validate last name
              onSaved: (v) => vm.lastName = v?.trim(), // Save trimmed value to ViewModel
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28), // Spacing before button
            // Next button to proceed to the next step
            AppButton(
              text: "Next",
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  FocusScope.of(context).unfocus(); // Hide keyboard
                  _formKey.currentState!.save(); // Save form data
                  vm.nextStep(); // Move to next step
                }
              },
              width: double.infinity,
              height: 52,
              useThemeGradient: true,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}