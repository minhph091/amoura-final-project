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
  bool _isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    // KHÔNG gọi fetchOrientationOptions ở đây nữa!
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
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
                      : Column(
                          children: [
                            GestureDetector(
                              onTap: _toggleDropdown,
                              child: ProfileOptionSelector(
                                options: step3ViewModel.orientationOptions,
                                selectedValue: step3ViewModel.orientationId,
                                onChanged: (value, selected) {
                                  if (selected && value.isNotEmpty) {
                                    final selectedOption = step3ViewModel.orientationOptions.firstWhere(
                                      (option) => option['value'] == value,
                                      orElse: () => {'value': '0', 'label': 'Unknown'},
                                    );
                                    step3ViewModel.setOrientation(selectedOption['value']!, selectedOption['label']!);
                                  }
                                },
                                labelText: 'Orientation',
                                labelStyle: ProfileTheme.getLabelStyle(context),
                                isDropdown: true,
                              ),
                            ),
                            if (_isDropdownOpen)
                              Container(
                                margin: const EdgeInsets.only(top: 8.0),
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: step3ViewModel.orientationOptions.map((option) {
                                    final isSelected = step3ViewModel.orientationId == option['value'];
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isDropdownOpen = false;
                                        });
                                        if (!isSelected && option['value']!.isNotEmpty) {
                                          step3ViewModel.setOrientation(option['value']!, option['label']!);
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? Colors.purple : Colors.grey.withOpacity(0.3),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        child: ListTile(
                                          leading: _getOrientationIcon(option['label']!),
                                          title: Text(
                                            option['label']!,
                                            style: ProfileTheme.getLabelStyle(context).copyWith(
                                              color: isSelected ? Colors.purple : Colors.black87,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          trailing: isSelected
                                              ? const Icon(Icons.check_circle, color: Colors.purple)
                                              : null,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
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

  Widget _getOrientationIcon(String label) {
    switch (label) {
      case 'Bisexual':
        return Icon(Icons.transgender, color: Colors.purple[300], size: 24);
      case 'Homosexual':
        return Icon(Icons.male, color: Colors.blue[300], size: 24);
      case 'Straight':
        return Icon(Icons.favorite, color: Colors.pink[300], size: 24);
      default:
        return const Icon(Icons.help, color: Colors.grey, size: 24);
    }
  }
}