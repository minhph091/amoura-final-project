// lib/presentation/auth/setup_profile/steps/step7_job_education_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../setup_profile_viewmodel.dart';

class Step7JobEducationForm extends StatefulWidget {
  const Step7JobEducationForm({super.key});
  @override
  State<Step7JobEducationForm> createState() => _Step7JobEducationFormState();
}

class _Step7JobEducationFormState extends State<Step7JobEducationForm> {
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context, listen: false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Replace with API
    final jobIndustries = [
      {'id': 1, 'name': 'IT'},
      {'id': 2, 'name': 'Education'},
      {'id': 3, 'name': 'Medical'},
      {'id': 4, 'name': 'Other'},
    ];
    final educationLevels = [
      {'id': 1, 'name': 'High School'},
      {'id': 2, 'name': 'Bachelor'},
      {'id': 3, 'name': 'Master'},
      {'id': 4, 'name': 'PhD'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Career & Education",
            style: AppTextStyles.heading2.copyWith(
              fontFamily: GoogleFonts.playfairDisplay().fontFamily,
              color: colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "Tell us about your work and education.",
            style: AppTextStyles.body.copyWith(
              fontFamily: GoogleFonts.lato().fontFamily,
              color: colorScheme.onSurface.withAlpha(179),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text(
                  "Job Industry",
                  style: TextStyle(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    color: colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                prefixIcon: Icon(Icons.work_outline, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.brightness == Brightness.light
                    ? AppColors.background
                    : AppColors.darkBackground,
              ),
              value: vm.jobIndustryId,
              items: jobIndustries.map((e) => DropdownMenuItem<int>(
                value: e['id'] as int,
                child: Row(
                  children: [
                    Icon(Icons.work, color: colorScheme.primary.withAlpha(153), size: 20),
                    const SizedBox(width: 7),
                    Text(
                      e['name'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontFamily: GoogleFonts.lato().fontFamily,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (val) => setState(() => vm.jobIndustryId = val),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                label: Text(
                  "Education Level",
                  style: TextStyle(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    color: colorScheme.onSurface.withAlpha(179),
                  ),
                ),
                prefixIcon: Icon(Icons.school, color: colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.brightness == Brightness.light
                    ? AppColors.background
                    : AppColors.darkBackground,
              ),
              value: vm.educationLevelId,
              items: educationLevels.map((e) => DropdownMenuItem<int>(
                value: e['id'] as int,
                child: Row(
                  children: [
                    Icon(Icons.school, color: colorScheme.primary.withAlpha(153), size: 20),
                    const SizedBox(width: 7),
                    Text(
                      e['name'] as String,
                      style: AppTextStyles.body.copyWith(
                        fontFamily: GoogleFonts.lato().fontFamily,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              )).toList(),
              onChanged: (val) => setState(() => vm.educationLevelId = val),
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I have dropped out / not completed the curriculum',
              style: AppTextStyles.body.copyWith(
                fontFamily: GoogleFonts.lato().fontFamily,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.left,
            ),
            trailing: Switch(
              value: vm.dropOut ?? false,
              onChanged: (val) => setState(() => vm.dropOut = val),
              activeColor: colorScheme.primary,
              inactiveThumbColor: colorScheme.onSurface.withAlpha(128),
              inactiveTrackColor: colorScheme.onSurface.withAlpha(51),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "Next",
                  onPressed: () => vm.nextStep(),
                  useThemeGradient: true, // Sử dụng gradient từ theme
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
