import 'package:flutter/material.dart';
import '../../../../core/constants/profile/job_constants.dart';
import '../../../../core/constants/profile/education_constants.dart';
import '../../../shared/widgets/profile_option_selector.dart';
import '../../setup/theme/setup_profile_theme.dart';
import '../../theme/profile_theme.dart';
import '../edit_profile_viewmodel.dart';

class EditProfileJobEducationSection extends StatefulWidget {
  final EditProfileViewModel viewModel;

  const EditProfileJobEducationSection({
    super.key,
    required this.viewModel,
  });

  @override
  State<EditProfileJobEducationSection> createState() => _EditProfileJobEducationSectionState();
}

class _EditProfileJobEducationSectionState extends State<EditProfileJobEducationSection> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Job & Education', style: ProfileTheme.getSubtitleStyle(context)),
            const SizedBox(height: 6),
            Text('Tell us about your career and education.',
                style: ProfileTheme.getDescriptionStyle(context)),
            const SizedBox(height: 16),

            // Job Industry Dropdown
            ProfileOptionSelector(
              options: jobOptions,
              selectedValue: widget.viewModel.jobIndustry,
              onChanged: (value, selected) {
                if (selected) {
                  setState(() => widget.viewModel.updateJobIndustry(value));
                }
              },
              labelText: 'Job Industry',
              labelStyle: ProfileTheme.getLabelStyle(context),
              isDropdown: true,
            ),

            const SizedBox(height: 18),

            // Education Level Dropdown
            ProfileOptionSelector(
              options: educationOptions,
              selectedValue: widget.viewModel.educationLevel,
              onChanged: (value, selected) {
                if (selected) {
                  setState(() => widget.viewModel.updateEducationLevel(value));
                }
              },
              labelText: 'Education Level',
              labelStyle: ProfileTheme.getLabelStyle(context),
              isDropdown: true,
            ),

            const SizedBox(height: 18),

            // Drop Out Toggle Switch
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'I have dropped out / not completed the curriculum',
                style: ProfileTheme.getInputTextStyle(context),
              ),
              trailing: Switch(
                value: widget.viewModel.dropOut ?? false,
                onChanged: (val) => setState(() => widget.viewModel.updateDropOut(val)),
                activeColor: ProfileTheme.darkPink,
                inactiveThumbColor: ProfileTheme.darkPurple.withAlpha(128),
                inactiveTrackColor: ProfileTheme.darkPurple.withAlpha(51),
              ),
            ),
          ],
        ),
      ),
    );
  }
}