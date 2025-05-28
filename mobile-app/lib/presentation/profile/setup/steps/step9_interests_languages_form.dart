// lib/presentation/profile/setup/steps/step9_interests_languages_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/shake_widget.dart';
import '../../shared/theme/profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/interest_constants.dart';
import '../../../../core/constants/profile/language_constants.dart';
import '../setup_profile_viewmodel.dart';

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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Interests & Languages', style: SetupProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('This helps us match you with like-minded people.', style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 8),
          Text('Fields marked with * are required.', style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: languageOptions,
            selectedValues: vm.selectedLanguageIds,
            onChanged: (value, selected) {
              setState(() {
                vm.selectedLanguageIds ??= [];
                if (selected) vm.selectedLanguageIds!.add(value);
                else vm.selectedLanguageIds!.remove(value);
              });
            },
            labelText: 'Languages you speak',
            labelStyle: SetupProfileTheme.getLabelStyle(context),
            isMultiSelect: true,
            scrollable: false,
            isSearchable: true,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text('Interested in learning new languages?', style: SetupProfileTheme.getInputTextStyle(context)),
            value: vm.interestedInNewLanguage ?? false,
            onChanged: (val) => setState(() => vm.interestedInNewLanguage = val ?? false),
            activeColor: SetupProfileTheme.darkPink,
          ),
          const SizedBox(height: 16),
          ShakeWidget(
            shake: _interestError,
            child: ProfileOptionSelector(
              options: interestOptions,
              selectedValues: vm.selectedInterestIds,
              onChanged: (value, selected) {
                setState(() {
                  vm.selectedInterestIds ??= [];
                  if (selected) vm.selectedInterestIds!.add(value);
                  else vm.selectedInterestIds!.remove(value);
                  _interestError = false;
                });
              },
              labelText: 'Your Interests *',
              labelStyle: SetupProfileTheme.getLabelStyle(context),
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
                    if (vm.selectedInterestIds == null || vm.selectedInterestIds!.isEmpty) {
                      setState(() => _interestError = true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one interest.')));
                    } else {
                      vm.nextStep(context: context);
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