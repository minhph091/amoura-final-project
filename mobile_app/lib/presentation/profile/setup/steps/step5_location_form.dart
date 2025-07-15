// lib/presentation/profile/setup/steps/step5_location_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/language/app_localizations.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../theme/setup_profile_theme.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';
import '../stepmodel/step5_viewmodel.dart';

class Step5LocationForm extends StatelessWidget {
  const Step5LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step5ViewModel = vm.stepViewModels[4] as Step5ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your Location", style: ProfileTheme.getTitleStyle(context)),
          const SizedBox(height: 6),
          Text(
            "This helps you connect with people nearby.",
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the GPS icon to automatically detect your location.",
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: step5ViewModel.cityController,
            labelText: "City",
            labelStyle: ProfileTheme.getLabelStyle(context),
            prefixIcon: Icons.location_city,
            prefixIconColor: ProfileTheme.darkPink,
            readOnly: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            style: ProfileTheme.getInputTextStyle(context),
            suffixIcon: _buildGpsButton(context, step5ViewModel),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: step5ViewModel.stateController,
            labelText: "State",
            labelStyle: ProfileTheme.getLabelStyle(context),
            prefixIcon: Icons.map,
            prefixIconColor: ProfileTheme.darkPink,
            readOnly: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            style: ProfileTheme.getInputTextStyle(context),
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: step5ViewModel.countryController,
            labelText: "Country",
            labelStyle: ProfileTheme.getLabelStyle(context),
            prefixIcon: Icons.flag,
            prefixIconColor: ProfileTheme.darkPink,
            readOnly: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            style: ProfileTheme.getInputTextStyle(context),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              "Preferred Distance (km)",
              style: ProfileTheme.getLabelStyle(context),
              textAlign: TextAlign.center,
            ),
          ),
          Selector<SetupProfileViewModel, int?>(
            selector: (_, vm) => vm.locationPreference,
            builder: (context, locationPreference, child) {
              return Slider(
                value:
                    (locationPreference ?? 50)
                        .toDouble(), // Default to 50 if null
                min: 1,
                max: 300,
                divisions: 30,
                label: "${locationPreference ?? 50} km",
                activeColor: ProfileTheme.darkPink,
                inactiveColor: ProfileTheme.darkPurple.withAlpha(77),
                onChanged: (val) {
                  vm.setLocationPreference(
                    val.round(),
                  ); // Call setLocationPreference to update value
                },
              );
            },
          ),
          const SizedBox(height: 28),
          SetupProfileButton(
            text: AppLocalizations.of(context).translate('next'),
            onPressed: () => vm.nextStep(context: context),
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildGpsButton(BuildContext context, Step5ViewModel step5ViewModel) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          print('GPS button tapped.');
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Permission'),
                  content: const Text(
                    'This app needs location access to fill address fields.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Deny'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Allow'),
                    ),
                  ],
                ),
          );
          if (result == true) {
            print(
              'User allowed location access, calling getCurrentLocation...',
            );
            await step5ViewModel.getCurrentLocation(context);
            print('Finished calling getCurrentLocation.');
          } else {
            print('User denied location access.');
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Permission denied")));
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ProfileTheme.darkPink.withAlpha(38),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.2),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder:
                (context, value, child) =>
                    Transform.scale(scale: value, child: child),
            child: Icon(
              Icons.gps_fixed,
              color: ProfileTheme.darkPink,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
