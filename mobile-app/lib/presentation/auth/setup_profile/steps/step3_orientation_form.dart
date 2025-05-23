// lib/presentation/auth/setup_profile/steps/step3_orientation_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

// Form for collecting user's sexual orientation during profile setup.
class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});

  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define sexual orientation options with appropriate icons and colors
    final orientations = [
      {
        'label': 'Attracted to Men',
        'icon': Icons.male,
        'value': 'men',
        'color': Colors.blue.shade700
      },
      {
        'label': 'Attracted to Women',
        'icon': Icons.female,
        'value': 'women',
        'color': Colors.pinkAccent.shade200
      },
      {
        'label': 'Attracted to Both',
        'icon': Icons.favorite,
        'value': 'both',
        'color': Colors.purple.shade600
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary title
          Text(
            "Your Orientation",
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          // Secondary description
          Text(
            "This helps us match you with compatible people.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please select your preference.",
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 32),

          // Orientation options displayed as cards for better visual emphasis
          ...orientations.map((orientation) {
            final isSelected = vm.orientationId == orientation['value'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: InkWell(
                onTap: () => setState(() => vm.orientationId = orientation['value'] as int?),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? orientation['color'] as Color
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: isSelected
                        ? (orientation['color'] as Color).withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (orientation['color'] as Color).withValues(
                            alpha: isSelected ? 1.0 : 0.2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          orientation['icon'] as IconData,
                          color: isSelected
                              ? Colors.white
                              : orientation['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        orientation['label'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? orientation['color'] as Color
                              : colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: orientation['color'] as Color,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 32),

          // Next button - enabled only when an orientation is selected
          AppButton(
            text: "Next",
            onPressed: vm.orientationId != null ? vm.nextStep : null,
            width: double.infinity,
            height: 52,
            gradient: vm.orientationId != null
                ? LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
            )
                : null,
            textStyle: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}