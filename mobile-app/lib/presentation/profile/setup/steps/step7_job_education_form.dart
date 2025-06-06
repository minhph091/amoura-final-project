// lib/presentation/profile/setup/steps/step7_job_education_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step7_viewmodel.dart';

class Step7JobEducationForm extends StatefulWidget {
  const Step7JobEducationForm({super.key});

  @override
  State<Step7JobEducationForm> createState() => _Step7JobEducationFormState();
}

class _Step7JobEducationFormState extends State<Step7JobEducationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step7ViewModel = vm.stepViewModels[6] as Step7ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Your Job & Education', style: ProfileTheme.getTitleStyle(context), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Tell us about your career and education.', style: ProfileTheme.getDescriptionStyle(context), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          step7ViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : step7ViewModel.errorMessage != null
                  ? Center(child: Text(step7ViewModel.errorMessage!, style: const TextStyle(color: Colors.red)))
                  : Column(
                      children: [
                        ProfileOptionSelector(
                          options: step7ViewModel.jobIndustryOptions,
                          selectedValue: step7ViewModel.jobIndustryId,
                          onChanged: (value, selected) {
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step7ViewModel.jobIndustryOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step7ViewModel.setJobIndustry(selectedOption['value'], selectedOption['label']);
                            }
                          },
                          labelText: 'Job Industry',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isDropdown: true,
                        ),
                        const SizedBox(height: 18),
                        ProfileOptionSelector(
                          options: step7ViewModel.educationLevelOptions,
                          selectedValue: step7ViewModel.educationLevelId,
                          onChanged: (value, selected) {
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step7ViewModel.educationLevelOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step7ViewModel.setEducationLevel(selectedOption['value'], selectedOption['label']);
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
                            value: step7ViewModel.dropOut ?? false,
                            onChanged: (val) => setState(() => step7ViewModel.setDropOut(val)),
                            activeColor: ProfileTheme.darkPink,
                            inactiveThumbColor: ProfileTheme.darkPurple.withAlpha(128),
                            inactiveTrackColor: ProfileTheme.darkPurple.withAlpha(51),
                          ),
                        ), // Removed invalid 'desenho'
                      ],
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