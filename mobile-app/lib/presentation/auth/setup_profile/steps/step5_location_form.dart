// lib/presentation/auth/setup_profile/steps/step5_location_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

class Step5LocationForm extends StatelessWidget {
  const Step5LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProfileViewModel>(
      builder: (context, vm, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Location",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "This helps you connect with people nearby.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 18),
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
              const SizedBox(height: 14),
              AppTextField(
                labelText: "City",
                prefixIcon: Icons.location_city,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.city ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 12),
              AppTextField(
                labelText: "State",
                prefixIcon: Icons.map,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.state ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 12),
              AppTextField(
                labelText: "Country",
                prefixIcon: Icons.flag,
                prefixIconColor: colorScheme.primary,
                initialValue: vm.country ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              const SizedBox(height: 20),
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
              Slider(
                value: (vm.locationPreference ?? 10).toDouble(),
                min: 1,
                max: 300,
                divisions: 30,
                label: "${vm.locationPreference ?? 10} km",
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurface.withAlpha(77),
                onChanged: (val) {
                  vm.setLocationPreference(val.round());
                },
              ),
              const SizedBox(height: 28),
              AppButton(
                text: "Next",
                width: double.infinity,
                onPressed: () => vm.nextStep(context),
                height: 52,
                gradient: LinearGradient(colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ]),
                textStyle: theme.textTheme.labelLarge,
              ),
              if (vm.showSkip)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextButton(
                    onPressed: () => vm.skipStep(),
                    child: const Text("Skip"),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}