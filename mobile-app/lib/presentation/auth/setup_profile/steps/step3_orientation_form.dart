// lib/presentation/auth/setup_profile/steps/step3_orientation_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});

  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18), // Padding for form content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Orientation",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6), // Spacing between title and description
          // Secondary description using bodyLarge from AppTheme
          Text(
            "This helps us match you with compatible people.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24), // Spacing before form fields (to be added)
          // Placeholder for orientation selection (to be implemented)
          const SizedBox(height: 28), // Spacing before button
          // Next button to proceed to the next step
          AppButton(
            text: "Next",
            onPressed: vm.orientationId != null ? vm.nextStep : null, // Enable button if orientation is selected
            width: double.infinity,
            height: 52,
            useThemeGradient: true,
            textStyle: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}