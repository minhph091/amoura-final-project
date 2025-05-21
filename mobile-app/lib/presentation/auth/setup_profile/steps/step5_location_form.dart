// lib/presentation/auth/setup_profile/steps/step5_location_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../setup_profile_viewmodel.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';

class Step5LocationForm extends StatelessWidget {
  const Step5LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    // Để slider và UI cập nhật khi locationPreference thay đổi, dùng Consumer
    return Consumer<SetupProfileViewModel>(
      builder: (context, vm, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Your Location",
                  style: GoogleFonts.dancingScript(
                    textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "We need your location to find matches near you.",
                  style: GoogleFonts.playfairDisplay(
                    textStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                    ),
                  ),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: GoogleFonts.lato().fontFamily,
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
                onPressed: () {
                  vm.nextStep();
                },
                height: 52,
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ]),
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}
