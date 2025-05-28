// lib/presentation/profile/setup/steps/step3_orientation_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/orientation_constants.dart';
import '../setup_profile_viewmodel.dart';
import '../theme/setup_profile_theme.dart';

class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});

  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Orientation', style: SetupProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('This helps us match you with compatible people.', style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 8),
          Text('Please select your preference.', style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 32),
          ProfileOptionSelector(
            options: orientationOptions,
            selectedValue: vm.orientation,
            onChanged: (value, selected) {
              if (selected) {
                setState(() => vm.orientation = value);
              }
            },
            labelText: 'Orientation',
            labelStyle: SetupProfileTheme.getLabelStyle(context),
            scrollable: false,
          ),
          const SizedBox(height: 32),
          SetupProfileButton(
            text: 'Next',
            onPressed: vm.orientation != null ? () => vm.nextStep(context: context) : null,
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}