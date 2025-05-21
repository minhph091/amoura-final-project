// lib/presentation/auth/setup_profile/steps/step8_lifestyle_form.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

class Step8LifestyleForm extends StatefulWidget {
  const Step8LifestyleForm({super.key});

  @override
  State<Step8LifestyleForm> createState() => _Step8LifestyleFormState();
}

class _Step8LifestyleFormState extends State<Step8LifestyleForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: true);
    final theme = Theme.of(context);

    // Dummy data (không API)
    final drinks = [
      {'id': 1, 'name': 'Never'},
      {'id': 2, 'name': 'Sometimes'},
      {'id': 3, 'name': 'Often'},
    ];
    final smokes = [
      {'id': 1, 'name': 'No'},
      {'id': 2, 'name': 'Occasionally'},
      {'id': 3, 'name': 'Regularly'},
    ];
    final pets = [
      {'id': 1, 'name': 'Dog', 'icon': Icons.pets},
      {'id': 2, 'name': 'Cat', 'icon': Icons.pets},
      {'id': 3, 'name': 'Bird', 'icon': Icons.pets},
      {'id': 4, 'name': 'Others', 'icon': Icons.pets},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lifestyle",
            style: theme.textTheme.displayMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayMedium?.fontFamily,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              letterSpacing: 1.05,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Tell us about your lifestyle and your pets.",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.label,
              fontStyle: FontStyle.italic,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 26),

          // Drink
          Text(
            "Do you drink?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayLarge?.fontFamily,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: const Text("Select"),
              prefixIcon: const Icon(Icons.local_bar, color: Colors.green),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.drinkStatusId,
            items: drinks.map((e) => DropdownMenuItem<int>(
              value: e['id'] as int,
              child: Row(
                children: [
                  Icon(Icons.local_bar, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Text(e['name'] as String, style: theme.textTheme.bodyMedium),
                ],
              ),
            )).toList(),
            onChanged: (val) => setState(() => vm.drinkStatusId = val),
          ),
          const SizedBox(height: 18),

          // Smoke
          Text(
            "Do you smoke?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayLarge?.fontFamily,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              label: const Text("Select"),
              prefixIcon: const Icon(Icons.smoking_rooms, color: Colors.red),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
            value: vm.smokeStatusId,
            items: smokes.map((e) => DropdownMenuItem<int>(
              value: e['id'] as int,
              child: Row(
                children: [
                  Icon(Icons.smoking_rooms, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Text(e['name'] as String, style: theme.textTheme.bodyMedium),
                ],
              ),
            )).toList(),
            onChanged: (val) => setState(() => vm.smokeStatusId = val),
          ),
          const SizedBox(height: 18),

          // Pets
          Text(
            "Do you have pets?",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: AppTheme.lightTheme.textTheme.displayLarge?.fontFamily,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: pets.map((p) {
              final isSelected = vm.selectedPetIds?.contains(p['id']) ?? false;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p['icon'] as IconData?, color: isSelected ? Colors.white : AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text(p['name'] as String),
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      vm.selectedPetIds = (vm.selectedPetIds ?? [])..add(p['id'] as int);
                    } else {
                      vm.selectedPetIds?.remove(p['id'] as int);
                    }
                  });
                },
                backgroundColor: AppColors.primary.withOpacity(0.08),
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),

          // Button dùng AppButton
          AppButton(
            text: "Next",
            onPressed: () => vm.nextStep(),
            useThemeGradient: true,
          ),
        ],
      ),
    );
  }
}