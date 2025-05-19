// lib/presentation/shared/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

// TextField custom cho toàn app
class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}