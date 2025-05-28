// lib/presentation/profile/shared/profile_field_edit_dialog.dart

import 'package:flutter/material.dart';

Future<void> showProfileFieldEditDialog({
  required BuildContext context,
  required String label,
  required String? initialValue,
  required String hintText,
  IconData? icon,
  int? maxLength,
  int? maxLines,
  String? Function(String?)? validator,
  required ValueChanged<String> onSaved,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
            Text('Edit $label'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              border: const OutlineInputBorder(),
            ),
            maxLength: maxLength,
            maxLines: maxLines ?? 1,
            validator: validator,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSaved(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}