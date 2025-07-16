import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';

class ProfileJobEducation extends StatelessWidget {
  final String? jobIndustry;
  final String? educationLevel;
  final bool? dropOut;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileJobEducation({
    super.key,
    this.jobIndustry,
    this.educationLevel,
    this.dropOut,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'Job Industry',
          value: jobIndustry,
          icon: Icons.work,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("jobIndustry") : null,
        ),
        ProfileFieldDisplay(
          label: 'Education Level',
          value: educationLevel,
          icon: Icons.school,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("educationLevel") : null,
        ),
        ProfileFieldDisplay(
          label: 'Drop Out',
          value: dropOut == null ? null : (dropOut! ? 'Yes' : 'No'),
          icon: Icons.info_outline,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("dropOut") : null,
          showDivider: false,
        ),
      ],
    );
  }
}
