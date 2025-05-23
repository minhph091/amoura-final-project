// lib/presentation/auth/setup_profile/steps/step9_interests_languages_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconly/flutter_iconly.dart'; // External icon library for general icons
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // External icon library for specific icons
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step9InterestsLanguagesForm extends StatefulWidget {
  const Step9InterestsLanguagesForm({super.key});

  @override
  State<Step9InterestsLanguagesForm> createState() => _Step9InterestsLanguagesFormState();
}

class _Step9InterestsLanguagesFormState extends State<Step9InterestsLanguagesForm> {
  // Hardcoded interests with corresponding icons
  final Map<String, IconData> _interests = {
    'art': FontAwesomeIcons.palette, // Specific icon for art
    'cooking': FontAwesomeIcons.utensils, // Specific icon for cooking
    'fitness': IconlyLight.activity, // General fitness icon
    'gaming': FontAwesomeIcons.gamepad, // Specific icon for gaming
    'movies': FontAwesomeIcons.film, // Specific icon for movies
    'music': FontAwesomeIcons.music, // Specific icon for music
    'nature': FontAwesomeIcons.tree, // Specific icon for nature
    'other': IconlyLight.category, // General icon for other
    'reading': FontAwesomeIcons.book, // Specific icon for reading
    'travel': FontAwesomeIcons.plane, // Specific icon for travel
    'volunteering': FontAwesomeIcons.handshakeAngle, // Specific icon for volunteering
  };

  // Hardcoded languages with a single icon (using a general language icon)
  final Map<String, IconData> _languages = {
    'arabic': FontAwesomeIcons.globe,
    'bengali': FontAwesomeIcons.globe,
    'english': FontAwesomeIcons.globe,
    'french': FontAwesomeIcons.globe,
    'german': FontAwesomeIcons.globe,
    'hindi': FontAwesomeIcons.globe,
    'italian': FontAwesomeIcons.globe,
    'japanese': FontAwesomeIcons.globe,
    'javanese': FontAwesomeIcons.globe,
    'korean': FontAwesomeIcons.globe,
    'mandarin': FontAwesomeIcons.globe,
    'marathi': FontAwesomeIcons.globe,
    'portuguese': FontAwesomeIcons.globe,
    'punjabi': FontAwesomeIcons.globe,
    'russian': FontAwesomeIcons.globe,
    'spanish': FontAwesomeIcons.globe,
    'tamil': FontAwesomeIcons.globe,
    'turkish': FontAwesomeIcons.globe,
    'urdu': FontAwesomeIcons.globe,
    'Vietnamese': FontAwesomeIcons.globe,
    'other': FontAwesomeIcons.globe,
  };

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
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
          const SizedBox(height: 6),
          // Secondary description using bodyLarge from AppTheme
          Text(
            "This helps us match you with like-minded people.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          // Italicized note for required fields using labelLarge from AppTheme
          Text(
            "Fields marked with * are required.",
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 18),
          // Language selection label
          Text(
            "Languages you speak",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Multi-select language options using FilterChip
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _languages.entries.map((entry) {
              final isSelected = vm.selectedLanguageIds?.contains(entry.key) ?? false;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.value, size: 20, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Text(entry.key),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    vm.selectedLanguageIds ??= [];
                    if (selected) {
                      vm.selectedLanguageIds!.add(entry.key);
                    } else {
                      vm.selectedLanguageIds!.remove(entry.key);
                    }
                  });
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          // Interest selection label
          Text(
            "Your Interests *",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Multi-select interest options using FilterChip
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.entries.map((entry) {
              final isSelected = vm.selectedInterestIds?.contains(entry.key) ?? false;
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(entry.value, size: 20, color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface),
                    const SizedBox(width: 4),
                    Text(entry.key),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    vm.selectedInterestIds ??= [];
                    if (selected) {
                      vm.selectedInterestIds!.add(entry.key);
                    } else {
                      vm.selectedInterestIds!.remove(entry.key);
                    }
                  });
                },
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
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