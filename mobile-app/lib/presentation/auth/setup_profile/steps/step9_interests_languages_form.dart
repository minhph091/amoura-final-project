// lib/presentation/auth/setup_profile/steps/step9_interests_languages_form.dart
// Form widget for collecting the user's interests and languages.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/shake_widget.dart';
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Interests & Languages',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: const Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This helps us match you with like-minded people.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fields marked with * are required.',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: languageOptions,
            selectedValues: vm.selectedLanguageIds,
            onChanged: (value, selected) {
              setState(() {
                vm.selectedLanguageIds ??= [];
                if (selected) {
                  vm.selectedLanguageIds!.add(value);
                } else {
                  vm.selectedLanguageIds!.remove(value);
                }
              });
            },
            labelText: 'Languages you speak',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isMultiSelect: true,
            scrollable: false,
            isSearchable: true,
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text(
              'Interested in learning new languages?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF424242),
              ),
            ),
            value: vm.interestedInNewLanguage ?? false,
            onChanged: (val) => setState(() => vm.interestedInNewLanguage = val ?? false),
            activeColor: const Color(0xFFD81B60),
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
                  if (selected) {
                    vm.selectedInterestIds!.add(value);
                  } else {
                    vm.selectedInterestIds!.remove(value);
                  }
                  _interestError = false;
                });
              },
              labelText: 'Your Interests *',
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFBA68C8),
                fontWeight: FontWeight.w600,
              ),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select at least one interest.')),
                      );
                    } else {
                      vm.nextStep();
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