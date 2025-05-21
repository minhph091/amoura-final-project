// lib/presentation/auth/setup_profile/steps/step9_interests_languages_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step9InterestsLanguagesForm extends StatefulWidget {
  const Step9InterestsLanguagesForm({super.key});

  @override
  State<Step9InterestsLanguagesForm> createState() => _Step9InterestsLanguagesFormState();
}

class _Step9InterestsLanguagesFormState extends State<Step9InterestsLanguagesForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Interests & Languages",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6), // Spacing between title and description
          // Secondary description using bodyLarge from AppTheme
          Text(
            "This helps us match you with like-minded people.",
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
          const SizedBox(height: 18), // Spacing before language selection
          // Language selection label
          Text(
            "Languages you speak",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8), // Spacing before language options
          // Placeholder for language selection (to be implemented)
          Wrap(
            spacing: 10,
            children: const [],
          ),
          const SizedBox(height: 12), // Spacing before checkbox
          // Checkbox for interest in learning new languages
          CheckboxListTile(
            title: Text(
              "Interested in learning new languages?",
              style: theme.textTheme.bodyLarge,
            ),
            value: vm.interestedInNewLanguage ?? false,
            onChanged: (val) => setState(() => vm.interestedInNewLanguage = val ?? false),
            activeColor: colorScheme.primary,
          ),
          const SizedBox(height: 16), // Spacing before interest selection
          // Interest selection label
          Text(
            "Your Interests *",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8), // Spacing before interest options
          // Placeholder for interest selection (to be implemented)
          Wrap(
            spacing: 8,
            children: const [],
          ),
          const SizedBox(height: 24), // Spacing before button
          // Next button to proceed to the next step
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "Next",
                  onPressed: () {
                    if (vm.selectedInterestIds == null || vm.selectedInterestIds!.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one interest.')),
                      );
                      return;
                    }
                    vm.nextStep();
                  },
                  useThemeGradient: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}