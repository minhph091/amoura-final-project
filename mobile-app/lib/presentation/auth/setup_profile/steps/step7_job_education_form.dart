// lib/presentation/auth/setup_profile/steps/step7_job_education_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step7JobEducationForm extends StatefulWidget {
  const Step7JobEducationForm({super.key});

  @override
  State<Step7JobEducationForm> createState() => _Step7JobEducationFormState();
}

class _Step7JobEducationFormState extends State<Step7JobEducationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Job & Education",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6), // Spacing between title and description
          // Secondary description using bodyLarge from AppTheme
          Text(
            "Tell us about your career and education.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24), // Spacing before form fields
          // Dropdown for job industry selection
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text(
                  "Job Industry",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                prefixIcon: Icon(Icons.work_outline, color: colorScheme.primary),
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
              value: vm.jobIndustryId,
              items: const [], // Placeholder for job industry options (from backend)
              onChanged: (val) => setState(() => vm.jobIndustryId = val),
            ),
          ),
          const SizedBox(height: 18), // Spacing between dropdowns
          // Dropdown for education level selection
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text(
                  "Education Level",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                prefixIcon: Icon(Icons.school, color: colorScheme.primary),
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
              value: vm.educationLevelId,
              items: const [], // Placeholder for education level options (from backend)
              onChanged: (val) => setState(() => vm.educationLevelId = val),
            ),
          ),
          const SizedBox(height: 18), // Spacing before switch
          // Switch for dropout status
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I have dropped out / not completed the curriculum',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.left,
            ),
            trailing: Switch(
              value: vm.dropOut ?? false,
              onChanged: (val) => setState(() => vm.dropOut = val),
              activeColor: colorScheme.primary,
              inactiveThumbColor: colorScheme.onSurface.withAlpha(128),
              inactiveTrackColor: colorScheme.onSurface.withAlpha(51),
            ),
          ),
          const SizedBox(height: 24), // Spacing before button
          // Next button to proceed to the next step
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "Next",
                  onPressed: () => vm.nextStep(),
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