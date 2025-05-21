// lib/presentation/auth/setup_profile/steps/step5_location_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart'; // Reusable text field widget
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step5LocationForm extends StatelessWidget {
  const Step5LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to update UI when locationPreference changes
    return Consumer<SetupProfileViewModel>(
      builder: (context, vm, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10), // Padding for form content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary title using headlineLarge from AppTheme
              Text(
                "Your Location",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6), // Spacing between title and description
              // Secondary description using bodyLarge from AppTheme
              Text(
                "This helps you connect with people nearby.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18), // Spacing before location button
              // Button to use current location
              AppButton(
                text: "Use Current Location",
                icon: Icons.my_location,
                onPressed: () {
                  // TODO: Request GPS and fill fields
                },
                useThemeGradient: true,
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              const SizedBox(height: 14), // Spacing before location fields
              // City input field (read-only)
              AppTextField(
                labelText: "City",
                prefixIcon: Icons.location_city,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.city ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 12), // Spacing between fields
              // State input field (read-only)
              AppTextField(
                labelText: "State",
                prefixIcon: Icons.map,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.state ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 12), // Spacing between fields
              // Country input field (read-only)
              AppTextField(
                labelText: "Country",
                prefixIcon: Icons.flag,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.country ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 20), // Spacing before distance slider
              // Preferred distance label
              Center(
                child: Text(
                  "Preferred Distance (km)",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Slider for preferred distance
              Slider(
                value: (vm.locationPreference ?? 10).toDouble(),
                min: 1,
                max: 300,
                divisions: 30,
                label: "${vm.locationPreference ?? 10} km",
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurface.withAlpha(77),
                onChanged: (val) {
                  vm.setLocationPreference(val.round()); // Update preferred distance
                },
              ),
              const SizedBox(height: 28), // Spacing before button
              // Next button to proceed to the next step
              AppButton(
                text: "Next",
                width: double.infinity,
                onPressed: () {
                  vm.nextStep();
                },
                height: 52,
                gradient: LinearGradient(colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ]),
                textStyle: theme.textTheme.labelLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}