import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileFieldEditInline extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String hintText;
  final IconData? icon;
  final bool required;
  final ValueChanged<String> onSaved;
  final VoidCallback? onCancel;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;

  const ProfileFieldEditInline({
    super.key,
    required this.label,
    this.initialValue,
    required this.hintText,
    this.icon,
    this.required = false,
    required this.onSaved,
    this.onCancel,
    this.validator,
    this.maxLength,
    this.maxLines,
  });

  @override
  State<ProfileFieldEditInline> createState() => _ProfileFieldEditInlineState();
}

class _ProfileFieldEditInlineState extends State<ProfileFieldEditInline> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? true) {
      widget.onSaved(_controller.text.trim());
    }
  }

  String? _validateField(String? value) {
    if (widget.required && (value == null || value.trim().isEmpty)) {
      return 'Please enter ${widget.label}';
    }
    return widget.validator != null ? widget.validator!(value) : null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListTile(
        leading: widget.icon != null ? Icon(widget.icon, color: ProfileTheme.darkPink, size: 22) : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.label,
                  style: ProfileTheme.getLabelStyle(context),
                ),
                if (widget.required)
                  Text(" *", style: TextStyle(color: ProfileTheme.darkPink, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: ProfileTheme.darkPink, width: 2),
                ),
              ),
              validator: _validateField,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines ?? 1,
              style: ProfileTheme.getInputTextStyle(context),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
              onPressed: _save,
              tooltip: 'Save',
            ),
            IconButton(
              icon: Icon(Icons.cancel, color: ProfileTheme.darkPink, size: 28),
              onPressed: widget.onCancel,
              tooltip: 'Cancel',
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
