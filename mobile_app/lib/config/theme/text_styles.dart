// lib/conig/theme/text_styles.dart

import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
  static const TextStyle heading2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 16, fontWeight: FontWeight.normal);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.1);

  static const TextTheme textTheme = TextTheme(
    displayLarge: heading1,
    displayMedium: heading2,
    bodyMedium: body,
    labelLarge: button,
  );
}
