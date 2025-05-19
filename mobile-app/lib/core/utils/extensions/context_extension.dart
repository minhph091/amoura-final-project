// lib/core/utils/extensions/context_extension.dart

import 'package:flutter/material.dart';

// Hàm mở rộng cho BuildContext để hiển thị SnackBar
extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}