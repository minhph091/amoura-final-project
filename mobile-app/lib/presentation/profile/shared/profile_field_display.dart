// lib/presentation/profile/shared/profile_field_display.dart

import 'package:flutter/material.dart';

class ProfileFieldDisplay extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final VoidCallback? onEdit;
  final bool showDivider;
  final bool editable;
  final Widget? customValueWidget;

  const ProfileFieldDisplay({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.onEdit,
    this.showDivider = true,
    this.editable = false,
    this.customValueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: icon != null ? Icon(icon, color: theme.colorScheme.primary, size: 22) : null,
          title: Text(label, style: theme.textTheme.bodyMedium),
          subtitle: customValueWidget ??
              Text(value?.isNotEmpty == true ? value! : '-', style: theme.textTheme.titleSmall),
          trailing: editable
              ? IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEdit,
            tooltip: 'Edit $label',
          )
              : null,
          dense: true,
          onTap: editable ? onEdit : null,
        ),
        if (showDivider) const Divider(height: 2),
      ],
    );
  }
}