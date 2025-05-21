// lib/presentation/auth/setup_profile/steps/step8_lifestyle_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Lifestyle",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6), // Spacing between title and description
          // Secondary description using bodyLarge from AppTheme
          Text(
            "Tell us about your lifestyle and pets.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24), // Spacing before form fields
          // Drinking status selection label
          Text(
            "Do you drink?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8), // Spacing before dropdown
          // Dropdown for drinking status
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: Text(
                "Select",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              prefixIcon: Icon(Icons.local_bar, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.drinkStatusId,
            items: const [], // Placeholder for drinking status options (from backend)
            onChanged: (val) => setState(() => vm.drinkStatusId = val),
          ),
          const SizedBox(height: 18), // Spacing before smoking status
          // Smoking status selection label
          Text(
            "Do you smoke?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8), // Spacing before dropdown
          // Dropdown for smoking status
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: Text(
                "Select",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              prefixIcon: Icon(Icons.smoking_rooms, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.smokeStatusId,
            items: const [], // Placeholder for smoking status options (from backend)
            onChanged: (val) => setState(() => vm.smokeStatusId = val),
          ),
          const SizedBox(height: 18), // Spacing before pet selection
          // Pet selection label
          Text(
            "Do you have pets?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8), // Spacing before pet options
          // Placeholder for pet selection (to be implemented)
          Wrap(
            spacing: 12,
            children: const [],
          ),
          const SizedBox(height: 30), // Spacing before button
          // Next button to proceed to the next step
          AppButton(
            text: "Next",
            onPressed: () => vm.nextStep(),
            useThemeGradient: true,
          ),
        ],
      ),
    );
  }
}