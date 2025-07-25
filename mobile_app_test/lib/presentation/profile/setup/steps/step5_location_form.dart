// lib/presentation/profile/setup/steps/step5_location_form.dart
// ignore_for_file: use_build_context_synchronously

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
    final localizations = AppLocalizations.of(context);
    final vm = Provider.of<SetupProfileViewModel>(context);
    final step5ViewModel = vm.stepViewModels[4] as Step5ViewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate('step5_title'),
            style: ProfileTheme.getTitleStyle(context),
          ),
          const SizedBox(height: 6),
          Text(
            localizations.translate('step5_description'),
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('gps_instruction'),
            style: ProfileTheme.getDescriptionStyle(context),
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: step5ViewModel.cityController,
            labelText: localizations.translate('city_label'),
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
            labelText: localizations.translate('state_label'),
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
            labelText: localizations.translate('country_label'),
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
            text: AppLocalizations.of(context).translate('continue_setup'),
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
          debugPrint('GPS button tapped.');
          final result = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('location_permission'),
                  ),
                  content: Text(
                    AppLocalizations.of(
                      context,
                    ).translate('permission_needed_location'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        AppLocalizations.of(context).translate('deny'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        AppLocalizations.of(context).translate('allow'),
                      ),
                    ),
                  ],
                ),
          );
          if (result == true) {
            debugPrint(
              'User allowed location access, calling getCurrentLocation...',
            );
            await step5ViewModel.getCurrentLocation(context);
            debugPrint('Finished calling getCurrentLocation.');
          } else {
            debugPrint('User denied location access.');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).translate('permission_denied'),
                ),
              ),
            );
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
