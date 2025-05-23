// lib/presentation/auth/setup_profile/steps/step8_lifestyle_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconly/flutter_iconly.dart'; // External icon library
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  // Hardcoded drinking status options with corresponding icons from flutter_iconly
  final Map<String, IconData> _drinkStatuses = {
    'heavily': IconlyLight.star, // Represents excessive drinking
    'never': IconlyLight.closeSquare, // Represents abstaining
    'occasionally': IconlyLight.timeCircle, // Represents occasional
    'prefer not to say': IconlyLight.hide, // Represents privacy
    'regularly': IconlyLight.activity, // Represents regular habit
    'socially': IconlyLight.user2, // Represents social drinking
  };

  // Hardcoded smoking status options with corresponding icons from flutter_iconly
  final Map<String, IconData> _smokeStatuses = {
    'former smoker': IconlyLight.logout, // Represents quitting
    'heavily': IconlyLight.star, // Represents excessive smoking
    'never': IconlyLight.closeSquare, // Represents abstaining
    'occasionally': IconlyLight.timeCircle, // Represents occasional
    'prefer not to say': IconlyLight.hide, // Represents privacy
    'regularly': IconlyLight.activity, // Represents regular habit
  };

  // Hardcoded pet options with corresponding icons from flutter_iconly
  final Map<String, IconData> _pets = {
    'bird': IconlyLight.star, // Placeholder (flutter_iconly doesn't have specific pet icons)
    'cat': IconlyLight.star,
    'dog': IconlyLight.star,
    'fish': IconlyLight.star,
    'hamster': IconlyLight.star,
    'horse': IconlyLight.star,
    'other': IconlyLight.star,
    'rabbit': IconlyLight.star,
    'reptile': IconlyLight.star,
  };

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Lifestyle",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          // Secondary description using bodyLarge from AppTheme
          Text(
            "Tell us about your lifestyle and pets.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Drinking status selection label
          Text(
            "Do you drink?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Dropdown for drinking status
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(
                "Select",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              prefixIcon: Icon(IconlyLight.activity, color: colorScheme.primary),
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
            value: vm.drinkStatusId != null ? _drinkStatuses.keys.elementAt(vm.drinkStatusId!) : null,
            items: _drinkStatuses.entries.map((entry) {
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
              final index = _drinkStatuses.keys.toList().indexOf(val!);
              setState(() => vm.drinkStatusId = index);
            },
          ),
          const SizedBox(height: 18),
          // Smoking status selection label
          Text(
            "Do you smoke?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Dropdown for smoking status
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(
                "Select",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              prefixIcon: Icon(IconlyLight.filter, color: colorScheme.primary),
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
            value: vm.smokeStatusId != null ? _smokeStatuses.keys.elementAt(vm.smokeStatusId!) : null,
            items: _smokeStatuses.entries.map((entry) {
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
              final index = _smokeStatuses.keys.toList().indexOf(val!);
              setState(() => vm.smokeStatusId = index);
            },
          ),
          const SizedBox(height: 18),
          // Pet selection label
          Text(
            "Do you have pets?",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Multi-select pet options using FilterChip
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _pets.entries.map((entry) {
              final isSelected = vm.selectedPets?.contains(entry.key) ?? false;
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
                    vm.selectedPets ??= [];
                    if (selected) {
                      vm.selectedPets!.add(entry.key);
                    } else {
                      vm.selectedPets!.remove(entry.key);
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
          const SizedBox(height: 30),
          // Next button to proceed to the next step
          AppButton(
            text: "Next",
            onPressed: () => vm.nextStep(),
            useThemeGradient: true,
          ),
        ],
      ),
    );
  }
}