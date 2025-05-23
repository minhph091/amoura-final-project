// lib/presentation/auth/setup_profile/steps/step5_location_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../widgets/setup_profile_button.dart';
import '../setup_profile_viewmodel.dart';

class Step5LocationForm extends StatelessWidget {
  const Step5LocationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SetupProfileViewModel>(
      builder: (context, vm, child) {
        final theme = Theme.of(context);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Location",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: const Color(0xFFD81B60),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "This helps you connect with people nearby.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFAB47BC),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tap the GPS icon to automatically detect your location.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFAB47BC),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              AppTextField(
                labelText: "City",
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8),
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icons.location_city,
                prefixIconColor: const Color(0xFFD81B60),
                initialValue: vm.city ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF424242),
                ),
                suffixIcon: _buildGpsButton(context),
              ),
              const SizedBox(height: 12),
              AppTextField(
                labelText: "State",
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8),
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icons.map,
                prefixIconColor: const Color(0xFFD81B60),
                initialValue: vm.state ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(
                labelText: "Country",
                labelStyle: theme.textTheme.titleMedium?.copyWith(
                  color: const Color(0xFFBA68C8),
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: Icons.flag,
                prefixIconColor: const Color(0xFFD81B60),
                initialValue: vm.country ?? "",
                readOnly: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Preferred Distance (km)",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFBA68C8),
                    fontWeight: FontWeight.w600,
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
                activeColor: const Color(0xFFD81B60),
                inactiveColor: const Color(0xFFBA68C8).withAlpha(77),
                onChanged: (val) {
                  vm.setLocationPreference(val.round());
                },
              ),
              const SizedBox(height: 28),
              SetupProfileButton(
                text: "Next",
                onPressed: () {
                  vm.nextStep();
                },
                width: double.infinity,
                height: 52,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGpsButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Show a permission dialog
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Location Permission'),
              content: const Text(
                'This app needs access to your location to fill the address fields automatically.',
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
            // Permission granted - API call would be handled by someone else
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Requesting your location...")),
            );
          } else {
            // Permission denied
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Location permission denied")),
            );
          }
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFD81B60).withAlpha(38), // 15% opacity
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.2),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: const Icon(
              Icons.gps_fixed,
              color: Color(0xFFD81B60),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}