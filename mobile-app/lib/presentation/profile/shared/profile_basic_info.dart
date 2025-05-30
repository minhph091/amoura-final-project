import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'profile_field_display.dart';
import 'theme/profile_theme.dart';

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
        ProfileFieldDisplay(
          label: 'Full Name',
          value: [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' '),
          icon: Icons.person,
          editable: editable,
          iconColor: ProfileTheme.darkPink,
          required: true,
          onEdit: onEdit != null ? () => onEdit!("name") : null,
        ),
        ProfileFieldDisplay(
          label: 'Username',
          value: username,
          icon: Icons.account_circle,
          iconColor: ProfileTheme.darkPink,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("username") : null,
        ),
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