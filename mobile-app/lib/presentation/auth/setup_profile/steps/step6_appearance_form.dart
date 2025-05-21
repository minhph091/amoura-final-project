// lib/presentation/auth/setup_profile/steps/step6_appearance_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../presentation/shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

class Step6AppearanceForm extends StatefulWidget {
  const Step6AppearanceForm({super.key});
  @override
  State<Step6AppearanceForm> createState() => _Step6AppearanceFormState();
}

class _Step6AppearanceFormState extends State<Step6AppearanceForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);

    final bodyTypes = [
      {'id': 1, 'name': 'Slim'},
      {'id': 2, 'name': 'Average'},
      {'id': 3, 'name': 'Muscular'},
      {'id': 4, 'name': 'Curvy'},
      {'id': 5, 'name': 'Unknown'},
    ];

    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              "Appearance",
              style: theme.textTheme.displayMedium?.copyWith(
                fontFamily: AppTheme.lightTheme.textTheme.displayMedium?.fontFamily,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Align(
            alignment: Alignment.center,
            child: Text(
              "Let others know more about your look.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Label "Body Type" giữ canh trái (hợp lý hơn)
          Text(
            "Body Type",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayLarge?.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: const Text("Select body type"),
              prefixIcon: const Icon(Icons.accessibility, color: AppColors.secondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.bodyTypeId,
            items: bodyTypes.map((e) =>
                DropdownMenuItem<int>(
                  value: e['id'] as int,
                  child: Row(
                    children: [
                      Icon(Icons.accessibility_new, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Text(e['name'] as String, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
            ).toList(),
            onChanged: (val) => setState(() => vm.bodyTypeId = val),
          ),
          const SizedBox(height: 20),

          // Label "Height (cm)" giữ canh trái (hợp lý hơn)
          Text(
            "Height (cm)",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayLarge?.fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.secondary,
            ),
          ),
          Slider(
            value: (vm.height ?? 170).toDouble(),
            min: 100,
            max: 220,
            divisions: 120,
            label: "${vm.height ?? 170} cm",
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => vm.height = val.round()),
          ),
          Center(
            child: Text(
              "${vm.height ?? 170} cm",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
  }
}
