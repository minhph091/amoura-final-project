// lib/presentation/auth/setup_profile/steps/step8_lifestyle_form.dart
// Form widget for collecting the user's lifestyle preferences, such as drinking, smoking, and pets.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/pet_constants.dart';
import '../../../../core/constants/profile/smoke_drink_constants.dart';
import '../setup_profile_viewmodel.dart';

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Lifestyle',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: const Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tell us about your lifestyle and pets.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: drinkOptions,
            selectedValue: vm.drinkStatus,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.drinkStatus = value);
              }
            },
            labelText: 'Do you drink?',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: smokeOptions,
            selectedValue: vm.smokeStatus,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.smokeStatus = value);
              }
            },
            labelText: 'Do you smoke?',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: petOptions,
            selectedValues: vm.selectedPets,
            onChanged: (value, selected) {
              setState(() {
                vm.selectedPets ??= [];
                if (selected) {
                  vm.selectedPets!.add(value);
                } else {
                  vm.selectedPets!.remove(value);
                }
              });
            },
            labelText: 'Do you have pets?',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isMultiSelect: true,
            scrollable: false, // Vertical layout
          ),
          const SizedBox(height: 30),
          SetupProfileButton(
            text: 'Next',
            onPressed: () => vm.nextStep(),
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}