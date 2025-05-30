// lib/presentation/profile/setup/steps/step7_job_education_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Job & Education', style: ProfileTheme.getTitleStyle(context), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Tell us about your career and education.', style: ProfileTheme.getDescriptionStyle(context), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: jobOptions,
            selectedValue: vm.jobIndustry,
            onChanged: (value, selected) {
              if (selected) {
                setState(() {
                  final index = jobOptions.indexWhere((option) => option['value'] == value);
                  vm.jobIndustryId = index;
                  vm.jobIndustry = value;
                });
              }
            },
            labelText: 'Job Industry',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: educationOptions,
            selectedValue: vm.educationLevel,
            onChanged: (value, selected) {
              if (selected) {
                setState(() {
                  final index = educationOptions.indexWhere((option) => option['value'] == value);
                  vm.educationLevelId = index;
                  vm.educationLevel = value;
                });
              }
            },
            labelText: 'Education Level',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('I have dropped out / not completed the curriculum', style: ProfileTheme.getInputTextStyle(context), textAlign: TextAlign.left),
            trailing: Switch(
              value: vm.dropOut ?? false,
              onChanged: (val) => setState(() => vm.dropOut = val),
              activeColor: ProfileTheme.darkPink,
              inactiveThumbColor: ProfileTheme.darkPurple.withAlpha(128),
              inactiveTrackColor: ProfileTheme.darkPurple.withAlpha(51),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SetupProfileButton(
                  text: 'Next',
                  onPressed: () => vm.nextStep(context: context),
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