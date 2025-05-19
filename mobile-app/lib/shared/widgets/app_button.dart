// lib/presentation/shared/widgets/app_button.dart

import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

// Nút bấm custom cho toàn app
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool outlined;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: outlined
          ? OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      )
          : ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}