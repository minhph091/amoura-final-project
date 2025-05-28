// // lib/presentation/profile/shared/profile_lifestyle.dart

import 'package:flutter/material.dart';
import 'profile_field_display.dart';

class ProfileLifestyle extends StatelessWidget {
  final String? drinkStatus;
  final String? smokeStatus;
  final List<String>? pets;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileLifestyle({
    super.key,
    this.drinkStatus,
    this.smokeStatus,
    this.pets,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'Drink',
          value: drinkStatus,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("drinkStatus") : null,
        ),
        ProfileFieldDisplay(
          label: 'Smoke',
          value: smokeStatus,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("smokeStatus") : null,
        ),
        ProfileFieldDisplay(
          label: 'Pets',
          value: pets != null && pets!.isNotEmpty ? pets!.join(', ') : null,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("pets") : null,
          showDivider: false,
        ),
      ],
    );
  }
}