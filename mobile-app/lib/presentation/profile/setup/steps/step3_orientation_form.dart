// lib/presentation/profile/setup/steps/step3_orientation_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step3_viewmodel.dart';

class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});

  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm> {
  @override
  void initState() {
    super.initState();
    // KHÔNG gọi fetchOrientationOptions ở đây nữa!
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step3ViewModel = vm.stepViewModels[2] as Step3ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Orientation', style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('This helps us match you with compatible people.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 8),
          Text('Please select your preference.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 32),
          step3ViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : step3ViewModel.errorMessage != null
                  ? Center(child: Text(step3ViewModel.errorMessage!, style: const TextStyle(color: Colors.red)))
                  : step3ViewModel.orientationOptions.isEmpty
                      ? const Center(child: Text('No orientation options available'))
                      : ProfileOptionSelector(
                          options: step3ViewModel.orientationOptions,
                          selectedValue: step3ViewModel.orientationId,
                          onChanged: (value, selected) {
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step3ViewModel.orientationOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step3ViewModel.setOrientation(selectedOption['value'] as String, selectedOption['label'] as String);
                            }
                          },
                          labelText: 'Orientation',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isDropdown: true,
                        ),
          const SizedBox(height: 32),
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