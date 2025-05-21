// lib/presentation/auth/setup_profile/steps/step3_orientation_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/app_theme.dart';
import '../setup_profile_viewmodel.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../presentation/shared/widgets/app_button.dart';

class Step3OrientationForm extends StatefulWidget {
  const Step3OrientationForm({super.key});
  @override
  State<Step3OrientationForm> createState() => _Step3OrientationFormState();
}

class _Step3OrientationFormState extends State<Step3OrientationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    final orientations = [
      {'id': 1, 'label': 'Straight', 'icon': Icons.straighten},
      {'id': 2, 'label': 'Gay', 'icon': Icons.wb_incandescent},
      {'id': 3, 'label': 'Bisexual', 'icon': Icons.compare_arrows},
      {'id': 4, 'label': 'Prefer not to say', 'icon': Icons.privacy_tip},
    ];

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Your Orientation Sexual",
              style: theme.textTheme.displayMedium?.copyWith(
                fontFamily: AppTheme.lightTheme.textTheme.displayMedium?.fontFamily,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 34,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Align(
            alignment: Alignment.center,
            child: Text(
              "Your name will be visible to other users.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...orientations.map((item) {
            final isSelected = vm.orientationId == item['id'];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  vm.setOrientation(item['id'] as int);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 170),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.purple.withValues(alpha: 0.10) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.purple : theme.colorScheme.outline.withValues(alpha: 0.28),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.07),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(item['icon'] as IconData, color: Colors.purple, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['label'] as String,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.purple : AppColors.text,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.purple, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),
          AppButton(
            text: "Next",
            onPressed: vm.orientationId != null ? vm.nextStep : null,
            width: double.infinity,
            height: 52,
            gradient: LinearGradient(colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ]),
            textStyle: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
