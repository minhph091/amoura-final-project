// lib/presentation/auth/setup_profile/steps/step9_interests_languages_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

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

    // TODO: fetch from API
    final languages = [
      {'id': 1, 'name': 'English'},
      {'id': 2, 'name': 'Vietnamese'},
      {'id': 3, 'name': 'Japanese'},
      {'id': 4, 'name': 'Spanish'},
    ];
    final interests = List.generate(20, (i) => {'id': i + 1, 'name': 'Interest ${i + 1}'});

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile Setup",
            style: theme.textTheme.displayMedium?.copyWith(
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Step 9: Interests & Languages *",
            style: theme.textTheme.displayLarge?.copyWith(
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              color: colorScheme.primary,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select at least one interest to help us match you. Fields marked * are required.",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: GoogleFonts.lato().fontFamily,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "Languages you speak",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: GoogleFonts.lato().fontFamily,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: languages.map((lang) {
              final selected = vm.selectedLanguageIds?.contains(lang['id']) ?? false;
              return FilterChip(
                label: Text(
                  lang['name'] as String,
                  style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                ),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      vm.selectedLanguageIds = (vm.selectedLanguageIds ?? [])..add(lang['id'] as int);
                    } else {
                      vm.selectedLanguageIds?.remove(lang['id'] as int);
                    }
                  });
                },
                selectedColor: colorScheme.primary.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontFamily: GoogleFonts.lato().fontFamily,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: Text(
              "Interested in learning new languages?",
              style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
            ),
            value: vm.interestedInNewLanguage ?? false,
            onChanged: (val) => setState(() => vm.interestedInNewLanguage = val ?? false),
            activeColor: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            "Your Interests *",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: GoogleFonts.lato().fontFamily,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: interests.map((interest) {
              final selected = vm.selectedInterestIds?.contains(interest['id']) ?? false;
              return FilterChip(
                label: Text(
                  interest['name'] as String,
                  style: TextStyle(fontFamily: GoogleFonts.lato().fontFamily),
                ),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      vm.selectedInterestIds = (vm.selectedInterestIds ?? [])..add(interest['id'] as int);
                    } else {
                      vm.selectedInterestIds?.remove(interest['id'] as int);
                    }
                  });
                },
                selectedColor: colorScheme.primary.withValues(alpha: 0.3),
                labelStyle: TextStyle(
                  color: selected ? colorScheme.primary : colorScheme.onSurface,
                  fontFamily: GoogleFonts.lato().fontFamily,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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