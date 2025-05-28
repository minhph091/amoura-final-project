// lib/presentation/profile/shared/profile_field_edit_inline.dart

import 'package:flutter/material.dart';

class ProfileFieldEditInline extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String hintText;
  final IconData? icon;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: ListTile(
        leading: widget.icon != null ? Icon(widget.icon, color: theme.colorScheme.primary, size: 22) : null,
        title: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
          ),
          validator: widget.validator,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _save,
              tooltip: 'Save',
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: widget.onCancel,
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }
}