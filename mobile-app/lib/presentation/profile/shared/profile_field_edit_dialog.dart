import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'theme/profile_theme.dart';

Future<void> showProfileFieldEditDialog({
  required BuildContext context,
  required String label,
  required String? initialValue,
  required String hintText,
  IconData? icon,
  bool required = false,
  int? maxLength,
  int? maxLines,
  String? Function(String?)? validator,
  required ValueChanged<String> onSaved,
}) async {
  final controller = TextEditingController(text: initialValue ?? '');
  final formKey = GlobalKey<FormState>();

  String? defaultValidator(String? value) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Please enter $label';
    }
    return validator != null ? validator(value) : null;
  }

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(icon, color: ProfileTheme.darkPink),
              ),
            Text(
              'Edit $label',
              style: TextStyle(color: ProfileTheme.darkPurple),
            ),
            if (required)
              Text(" *", style: TextStyle(color: ProfileTheme.darkPink, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: ProfileTheme.darkPurple),
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ProfileTheme.darkPink, width: 2),
              ),
              prefixIcon: icon != null ? Icon(icon, color: ProfileTheme.darkPink) : null,
            ),
            maxLength: maxLength,
            maxLines: maxLines ?? 1,
            validator: defaultValidator,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: ProfileTheme.darkPurple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileTheme.darkPink,
              foregroundColor: Colors.white,
            ),
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