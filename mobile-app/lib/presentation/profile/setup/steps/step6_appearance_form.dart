// lib/presentation/profile/setup/steps/step6_appearance_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../../../core/constants/profile/body_type_constants.dart';
import '../setup_profile_viewmodel.dart';
import '../theme/setup_profile_theme.dart';

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});

  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Appearance', style: SetupProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('Let others know more about your look.', style: SetupProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 24),
          ProfileOptionSelector(
            options: bodyTypeOptions,
            selectedValue: vm.bodyType,
            onChanged: (value, selected) {
              if (selected) setState(() => vm.bodyType = value);
            },
            labelText: 'Body Type',
            labelStyle: SetupProfileTheme.getLabelStyle(context),
            isDropdown: true,
          ),
          const SizedBox(height: 20),
          Text('Height (cm)', style: SetupProfileTheme.getLabelStyle(context)),
          Slider(
            value: (vm.height ?? 170).toDouble(),
            min: 100,
            max: 220,
            divisions: 120,
            label: '${vm.height ?? 170} cm',
            activeColor: SetupProfileTheme.darkPink,
            inactiveColor: SetupProfileTheme.darkPurple.withAlpha(77),
            onChanged: (val) => setState(() => vm.height = val.round()),
          ),
          Center(
            child: Text('${vm.height ?? 170} cm', style: SetupProfileTheme.getTitleStyle(context).copyWith(fontSize: 16)),
          ),
          const SizedBox(height: 28),
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