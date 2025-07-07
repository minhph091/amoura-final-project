// lib/core/utils/extensions/context_extension.dart

import 'package:flutter/material.dart';

// An extension on [BuildContext] to simplify showing SnackBars.
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
