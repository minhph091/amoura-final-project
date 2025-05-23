// lib/presentation/auth/setup_profile/steps/step6_appearance_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart'; // Reusable button widget
import '../setup_profile_viewmodel.dart'; // ViewModel for managing setup profile state

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});

  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
  // Hardcoded body type options with corresponding icons
  final Map<String, IconData> _bodyTypes = {
    'athletic': Icons.fitness_center,
    'average': Icons.person_outline,
    'curvy': Icons.woman,
    'fit': Icons.directions_run,
    'prefer not to say': Icons.privacy_tip,
    'slim': Icons.trending_flat,
  };

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title using headlineLarge from AppTheme
          Text(
            "Your Appearance",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          // Secondary description using bodyLarge from AppTheme
          Text(
            "Let others know more about your look.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          // Body type selection label
          Text(
            "Body Type",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          // Dropdown for body type selection with icons
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              label: Text(
                "Select body type",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              prefixIcon: Icon(Icons.accessibility, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.bodyTypeId != null ? _bodyTypes.keys.elementAt(vm.bodyTypeId!) : null,
            items: _bodyTypes.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Icon(entry.value, size: 20, color: colorScheme.onSurface),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              final index = _bodyTypes.keys.toList().indexOf(val!);
              setState(() => vm.bodyTypeId = index);
            },
          ),
          const SizedBox(height: 20),
          // Height selection label
          Text(
            "Height (cm)",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          // Slider for height selection
          Slider(
            value: (vm.height ?? 170).toDouble(),
            min: 100,
            max: 220,
            divisions: 120,
            label: "${vm.height ?? 170} cm",
            activeColor: colorScheme.primary,
            inactiveColor: colorScheme.onSurface.withValues(alpha: 0.3),
            onChanged: (val) => setState(() => vm.height = val.round()),
          ),
          // Display selected height
          Center(
            child: Text(
              "${vm.height ?? 170} cm",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 28),
          // Next button to proceed to the next step
          AppButton(
            text: "Next",
            width: double.infinity,
            onPressed: () => vm.nextStep(),
            height: 52,
            useThemeGradient: true,
          ),
        ],
      ),
    );
  }
}