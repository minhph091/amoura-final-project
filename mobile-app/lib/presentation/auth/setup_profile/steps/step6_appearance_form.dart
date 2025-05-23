// lib/presentation/auth/setup_profile/steps/step6_appearance_form.dart
// Form widget for collecting the user's appearance details, such as body type and height.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/body_type_constants.dart';
import '../setup_profile_viewmodel.dart';

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});

  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
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
            'Your Appearance',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: const Color(0xFFD81B60),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let others know more about your look.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFAB47BC),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: bodyTypeOptions,
            selectedValue: vm.bodyType,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.bodyType = value);
              }
            },
            labelText: 'Body Type',
            labelStyle: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
            isDropdown: true,
          ),
          const SizedBox(height: 20),
          Text(
            'Height (cm)',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFFBA68C8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Slider(
            value: (vm.height ?? 170).toDouble(),
            min: 100,
            max: 220,
            divisions: 120,
            label: '${vm.height ?? 170} cm',
            activeColor: const Color(0xFFD81B60),
            inactiveColor: const Color(0xFFBA68C8).withAlpha(77),
            onChanged: (val) {
              setState(() => vm.height = val.round());
            },
          ),
          Center(
            child: Text(
              '${vm.height ?? 170} cm',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFFD81B60),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 28),
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