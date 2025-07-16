// lib/presentation/shared/dialogs/alert_dialog.dart

import 'package:flutter/material.dart';

Future<void> showAppAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
  String buttonText = "OK",
  VoidCallback? onConfirm,
  IconData icon = Icons.info_rounded,
  Color? iconColor,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(content),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm?.call();
          },
          child: Text(buttonText),
        ),
      ],
    ),
  );
}
