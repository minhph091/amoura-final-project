import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileFieldDisplay extends StatelessWidget {
  final String label;
  final String? value;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onEdit;
  final bool showDivider;
  final bool editable;
  final bool required;
  final Widget? customValueWidget;

  const ProfileFieldDisplay({
    super.key,
    required this.label,
    this.value,
    this.icon,
    this.iconColor,
    this.onEdit,
    this.showDivider = true,
    this.editable = false,
    this.required = false,
    this.customValueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: icon != null ? Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 22) : null,
          title: Row(
            children: [
              Text(
                label,
                style: ProfileTheme.getLabelStyle(context),
              ),
              if (required)
                Text(" *", style: TextStyle(color: ProfileTheme.darkPink, fontWeight: FontWeight.bold)),
            ],
          ),
          subtitle: customValueWidget ??
              Text(
                value?.isNotEmpty == true ? value! : '-',
                style: ProfileTheme.getInputTextStyle(context),
              ),
          trailing: editable
              ? IconButton(
            icon: Icon(Icons.edit, size: 20, color: ProfileTheme.darkPink),
            onPressed: onEdit,
            tooltip: 'Edit $label',
          )
              : null,
          dense: true,
          onTap: editable ? onEdit : null,
        ),
        if (showDivider) Divider(height: 2, color: ProfileTheme.lightPurple),
      ],
    );
  }
}