// lib/presentation/profile/shared/profile_basic_info.dart

import 'package:flutter/material.dart';
import 'profile_field_display.dart';

class ProfileBasicInfo extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? gender;
  final String? orientation;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileBasicInfo({
    super.key,
    this.firstName,
    this.lastName,
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
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("name") : null,
        ),
        ProfileFieldDisplay(
          label: 'Birthday',
          value: dob != null ? "${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}" : null,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("dob") : null,
        ),
        ProfileFieldDisplay(
          label: 'Gender',
          value: gender,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("gender") : null,
        ),
        ProfileFieldDisplay(
          label: 'Orientation',
          value: orientation,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("orientation") : null,
          showDivider: false,
        ),
      ],
    );
  }
}