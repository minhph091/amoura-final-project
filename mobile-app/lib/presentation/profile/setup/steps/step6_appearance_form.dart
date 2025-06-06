// lib/presentation/profile/setup/steps/step6_appearance_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step6_viewmodel.dart';

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});

  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
  @override
  void initState() {
    super.initState();
    // KHÔNG gọi fetchBodyTypeOptions ở đây nữa!
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final step6ViewModel = vm.stepViewModels[5] as Step6ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Appearance', style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('Let others know more about your look.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 24),
          step6ViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : step6ViewModel.errorMessage != null
                  ? Center(child: Text(step6ViewModel.errorMessage!, style: const TextStyle(color: Colors.red)))
                  : step6ViewModel.bodyTypeOptions.isEmpty
                      ? const Center(child: Text('No body type options available'))
                      : ProfileOptionSelector(
                          options: (() {
                            print('DEBUG options: ${step6ViewModel.bodyTypeOptions}');
                            return step6ViewModel.bodyTypeOptions;
                          })(),
                          selectedValue: (() {
                            print('DEBUG selectedValue: ${step6ViewModel.bodyTypeId}');
                            return step6ViewModel.bodyTypeId;
                          })(),
                          onChanged: (value, selected) {
                            print('DEBUG onChanged: value=$value, selected=$selected');
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step6ViewModel.bodyTypeOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step6ViewModel.setBodyType(selectedOption['value'] as String, selectedOption['label'] as String);
                            }
                          },
                          labelText: 'Body Type',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isDropdown: true,
                        ),
          const SizedBox(height: 20),
          Text('Height (cm)', style: ProfileTheme.getLabelStyle(context)),
          Slider(
            value: (step6ViewModel.height ?? 170).toDouble(),
            min: 100,
            max: 250,
            divisions: 150,
            label: '${step6ViewModel.height ?? 170} cm',
            activeColor: ProfileTheme.darkPink,
            inactiveColor: ProfileTheme.darkPurple.withAlpha(77),
            onChanged: (val) {
              step6ViewModel.setHeight(val.round());
            },
          ),
          Center(
            child: Text(
              '${step6ViewModel.height ?? 170} cm',
              style: ProfileTheme.getTitleStyle(context).copyWith(fontSize: 16),
            ),
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