// lib/presentation/profile/shared/profile_appearance.dart

import 'package:flutter/material.dart';
import 'profile_field_display.dart';

class ProfileAppearance extends StatelessWidget {
  final String? bodyType;
  final int? height;
  final bool editable;
  final void Function(String field)? onEdit;

  const ProfileAppearance({
    super.key,
    this.bodyType,
    this.height,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileFieldDisplay(
          label: 'Body Type',
          value: bodyType,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("bodyType") : null,
        ),
        ProfileFieldDisplay(
          label: 'Height',
          value: height != null ? '$height cm' : null,
          editable: editable,
          onEdit: onEdit != null ? () => onEdit!("height") : null,
          showDivider: false,
        ),
      ],
    );
  }
}