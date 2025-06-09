// lib/presentation/profile/setup/steps/step9_interests_languages_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/interest_constants.dart';
import '../../../../core/constants/profile/language_constants.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step9_viewmodel.dart'; // Thêm import Step9ViewModel

class Step9InterestsLanguagesForm extends StatefulWidget {
  const Step9InterestsLanguagesForm({super.key});

  @override
  State<Step9InterestsLanguagesForm> createState() => _Step9InterestsLanguagesFormState();
}

class _Step9InterestsLanguagesFormState extends State<Step9InterestsLanguagesForm> {
  bool _interestError = false;

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step9ViewModel = vm.stepViewModels[8] as Step9ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Interests & Languages', style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('This helps us match you with like-minded people.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 8),
          Text('Fields marked with * are required.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: step9ViewModel.languageOptions,
            selectedValues: step9ViewModel.selectedLanguageIds ?? [],
            onChanged: (value, selected) {
              setState(() {
                final updatedLanguages = step9ViewModel.selectedLanguageIds ?? [];
                if (selected) updatedLanguages.add(value);
                else updatedLanguages.remove(value);
                step9ViewModel.setSelectedLanguageIds(updatedLanguages);
              });
            },
            labelText: 'Languages you speak',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isMultiSelect: true,
            scrollable: false,
            isSearchable: true,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text('Interested in learning new languages?', style: ProfileTheme.getInputTextStyle(context)),
            value: step9ViewModel.interestedInNewLanguage ?? false,
            onChanged: (val) => setState(() => step9ViewModel.setInterestedInNewLanguage(val ?? false)),
            activeColor: ProfileTheme.darkPink,
          ),
          const SizedBox(height: 16),
          ShakeWidget(
            shake: _interestError,
            child: ProfileOptionSelector(
              options: step9ViewModel.interestOptions,
              selectedValues: step9ViewModel.selectedInterestIds ?? [],
              onChanged: (value, selected) {
                setState(() {
                  final updatedInterests = step9ViewModel.selectedInterestIds ?? [];
                  if (selected) updatedInterests.add(value);
                  else updatedInterests.remove(value);
                  step9ViewModel.setSelectedInterestIds(updatedInterests);
                  _interestError = false;
                });
              },
              labelText: 'Your Interests *',
              labelStyle: ProfileTheme.getLabelStyle(context),
              isMultiSelect: true,
              scrollable: false,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SetupProfileButton(
                  text: 'Next',
                  onPressed: () {
                    final error = vm.validateCurrentStep() ?? step9ViewModel.validate();
                    if (error == null) {
                      vm.nextStep(context: context);
                    } else {
                      setState(() => _interestError = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
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