// lib/presentation/auth/setup_profile/steps/step7_job_education_form.dart
// Form widget for collecting the user's job and education details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/education_constants.dart';
import '../../../../core/constants/profile/job_constants.dart';
import '../setup_profile_viewmodel.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Job & Education',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: const Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us about your career and education.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: jobOptions,
            selectedValue: vm.jobIndustry,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.jobIndustry = value);
              }
            },
            labelText: 'Job Industry',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: educationOptions,
            selectedValue: vm.educationLevel,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.educationLevel = value);
              }
            },
            labelText: 'Education Level',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I have dropped out / not completed the curriculum',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF424242),
              ),
              textAlign: TextAlign.left,
            ),
            trailing: Switch(
              value: vm.dropOut ?? false,
              onChanged: (val) {
                setState(() => vm.dropOut = val);
              },
              activeColor: const Color(0xFFD81B60),
              inactiveThumbColor: const Color(0xFFBA68C8).withAlpha(128),
              inactiveTrackColor: const Color(0xFFBA68C8).withAlpha(51),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SetupProfileButton(
                  text: 'Next',
                  onPressed: () => vm.nextStep(),
                  width: double.infinity,
                  height: 52,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}