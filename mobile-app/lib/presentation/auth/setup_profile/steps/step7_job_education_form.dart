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
  // Hardcoded job industry options with corresponding icons
  final Map<String, IconData> _jobIndustries = {
    'creative': Icons.brush,
    'education': Icons.school,
    'engineering': Icons.build,
    'finance': Icons.account_balance,
    'healthcare': Icons.local_hospital,
    'hospitality': Icons.local_dining,
    'it': Icons.computer,
    'legal/gov': Icons.gavel,
    'no occupation': Icons.work_off,
    'other': Icons.category,
    'skilled labor': Icons.construction,
  };

  // Hardcoded education level options with corresponding icons
  final Map<String, IconData> _educationLevels = {
    "bachelor's degree": Icons.school_outlined,
    'college': Icons.account_balance_outlined,
    'high school': Icons.book_outlined,
    "master's degree": Icons.school,
    'phd': Icons.star,
  };

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
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
          const SizedBox(height: 6),
          // Secondary description using bodyLarge from AppTheme
          Text(
            "Tell us about your career and education.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Dropdown for job industry selection
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
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
              value: vm.jobIndustryId != null ? _jobIndustries.keys.elementAt(vm.jobIndustryId!) : null,
              items: _jobIndustries.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 20, color: colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                final index = _jobIndustries.keys.toList().indexOf(val!);
                setState(() => vm.jobIndustryId = index);
              },
            ),
          ),
          const SizedBox(height: 18),
          // Dropdown for education level selection
          SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
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
              value: vm.educationLevelId != null ? _educationLevels.keys.elementAt(vm.educationLevelId!) : null,
              items: _educationLevels.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(entry.value, size: 20, color: colorScheme.onSurface),
                      const SizedBox(width: 8),
                      Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                final index = _educationLevels.keys.toList().indexOf(val!);
                setState(() => vm.educationLevelId = index);
              },
            ),
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 24),
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