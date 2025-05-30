// lib/presentation/profile/setup/steps/step8_lifestyle_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Lifestyle', style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('Tell us about your lifestyle and pets.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: drinkOptions,
            selectedValue: vm.drinkStatus,
            onChanged: (value, selected) {
              if (selected) setState(() => vm.drinkStatus = value);
            },
            labelText: 'Do you drink?',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: smokeOptions,
            selectedValue: vm.smokeStatus,
            onChanged: (value, selected) {
              if (selected) setState(() => vm.smokeStatus = value);
            },
            labelText: 'Do you smoke?',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isDropdown: true,
          ),
          const SizedBox(height: 18),
          ProfileOptionSelector(
            options: petOptions,
            selectedValues: vm.selectedPets,
            onChanged: (value, selected) {
              setState(() {
                vm.selectedPets ??= [];
                if (selected) vm.selectedPets!.add(value);
                else vm.selectedPets!.remove(value);
              });
            },
            labelText: 'Do you have pets?',
            labelStyle: ProfileTheme.getLabelStyle(context),
            isMultiSelect: true,
            scrollable: false,
          ),
          const SizedBox(height: 30),
          SetupProfileButton(
            text: 'Next',
            onPressed: () => vm.nextStep(context: context),
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}