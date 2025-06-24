import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
            icon,
            color: iconColor ?? colorScheme.onSurfaceVariant,
            size: 22
        ),
        title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: titleColor,
            )
        ),
        subtitle: subtitle != null
            ? Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85)
            )
        )
            : null,
        trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        hoverColor: colorScheme.primary.withValues(alpha: 0.03),
      ),
    );
  }
}