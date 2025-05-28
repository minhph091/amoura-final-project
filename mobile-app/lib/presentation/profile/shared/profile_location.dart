// lib/presentation/profile/shared/profile_location.dart

import 'package:flutter/material.dart';
import 'profile_field_display.dart';

class ProfileLocation extends StatelessWidget {
  final String? city;
  final String? state;
  final String? country;
  final int? locationPreference;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileLocation({
    super.key,
    this.city,
    this.state,
    this.country,
    this.locationPreference,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'City',
          value: city,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("city") : null,
        ),
        ProfileFieldDisplay(
          label: 'State',
          value: state,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("state") : null,
        ),
        ProfileFieldDisplay(
          label: 'Country',
          value: country,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("country") : null,
        ),
        ProfileFieldDisplay(
          label: 'Preferred Distance',
          value: locationPreference != null ? '$locationPreference km' : null,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("distance") : null,
          showDivider: false,
        ),
      ],
    );
  }
}