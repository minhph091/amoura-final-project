// lib/presentation/profile/shared/profile_basic_info.dart
import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';

class ProfileBasicInfo extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final String? username;
  final DateTime? dob;
  final String? gender;
  final String? orientation;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileBasicInfo({
    super.key,
    this.firstName,
    this.lastName,
    this.username,
    this.dob,
    this.gender,
    this.orientation,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Removed duplicate Full Name and Username fields since they're shown in the header
        ProfileFieldDisplay(
          label: 'Birthday',
          value: dob != null ? "${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}" : null,
          icon: Icons.cake_rounded,
          iconColor: ProfileTheme.darkPink,
          required: true,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("dob") : null,
        ),
        ProfileFieldDisplay(
          label: 'Gender',
          value: gender,
          icon: Icons.person_outline,
          iconColor: ProfileTheme.darkPink,
          required: true,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("gender") : null,
        ),
        ProfileFieldDisplay(
          label: 'Orientation',
          value: orientation,
          icon: Icons.favorite,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("orientation") : null,
          showDivider: false,
        ),
      ],
    );
  }
}