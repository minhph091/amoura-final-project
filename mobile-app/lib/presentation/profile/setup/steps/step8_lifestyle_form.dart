// lib/presentation/profile/setup/steps/step8_lifestyle_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step8_viewmodel.dart';

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final step8ViewModel = vm.stepViewModels[7] as Step8ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Lifestyle', style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text('Tell us about your lifestyle and pets.', style: ProfileTheme.getDescriptionStyle(context)),
          const SizedBox(height: 24),
          step8ViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : step8ViewModel.errorMessage != null
                  ? Center(child: Text(step8ViewModel.errorMessage!, style: const TextStyle(color: Colors.red)))
                  : Column(
                      children: [
                        ProfileOptionSelector(
                          options: step8ViewModel.drinkStatusOptions,
                          selectedValue: step8ViewModel.drinkStatusId,
                          onChanged: (value, selected) {
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step8ViewModel.drinkStatusOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step8ViewModel.setDrinkStatus(selectedOption['value'], selectedOption['label']);
                            }
                          },
                          labelText: 'Do you drink?',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isDropdown: true,
                        ),
                        const SizedBox(height: 18),
                        ProfileOptionSelector(
                          options: step8ViewModel.smokeStatusOptions,
                          selectedValue: step8ViewModel.smokeStatusId,
                          onChanged: (value, selected) {
                            if (selected && value.isNotEmpty) {
                              final selectedOption = step8ViewModel.smokeStatusOptions.firstWhere(
                                (option) => option['value'] == value,
                                orElse: () => {'value': '0', 'label': 'Unknown'},
                              );
                              step8ViewModel.setSmokeStatus(selectedOption['value'], selectedOption['label']);
                            }
                          },
                          labelText: 'Do you smoke?',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isDropdown: true,
                        ),
                        const SizedBox(height: 18),
                        ProfileOptionSelector(
                          options: step8ViewModel.petOptions,
                          selectedValues: step8ViewModel.selectedPets,
                          onChanged: (value, selected) {
                            setState(() {
                              step8ViewModel.selectedPets ??= [];
                              if (selected) {
                                step8ViewModel.selectedPets!.add(value);
                              } else {
                                step8ViewModel.selectedPets!.remove(value);
                              }
                              step8ViewModel.setSelectedPets(step8ViewModel.selectedPets!);
                            });
                          },
                          labelText: 'Do you have pets?',
                          labelStyle: ProfileTheme.getLabelStyle(context),
                          isMultiSelect: true,
                          scrollable: false,
                        ),
                      ],
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