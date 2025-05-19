// lib/presentation/shared/dialogs/alert_dialog.dart

import 'package:flutter/material.dart';

Future<bool?> showAppAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  IconData? icon,
  String confirmText = "OK",
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Color? iconColor,
}) {
  final theme = Theme.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: cancelText != null,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            CircleAvatar(
              backgroundColor: (iconColor ?? theme.colorScheme.primary).withOpacity(0.12),
              radius: 28,
              child: Icon(icon, size: 36, color: iconColor ?? theme.colorScheme.primary),
            ),
          if (icon != null) const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
              onCancel?.call();
            },
            child: Text(cancelText, style: TextStyle(color: theme.colorScheme.secondary)),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(ctx).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}