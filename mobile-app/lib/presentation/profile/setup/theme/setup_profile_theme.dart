// lib/presentation/profile/setup/theme/setup_profile_theme.dart

import 'package:flutter/material.dart';

class SetupProfileTheme {
  static const Color lightPink = Color(0xFFFEEAE6); // Soft pink
  static const Color lightPurple = Color(0xFFF3E5F5); // Light purple
  static const Color lightBlue = Color(0xFFE3F2FD); // Light blue
  static const Color darkPink = Color(0xFFD81B60); // Accent pink
  static const Color darkPurple = Color(0xFF8E24AA); // Accent purple
  static const Color darkBlue = Color(0xFF1976D2); // Accent blue

  static TextStyle getTitleStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.textTheme.headlineLarge?.copyWith(
      color: isDark ? lightPink : darkPink,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ) ?? const TextStyle(
      color: darkPink,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    );
  }

  static TextStyle getDescriptionStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.textTheme.bodyLarge?.copyWith(
      color: isDark ? lightPurple : Colors.grey[600]!,
      fontStyle: FontStyle.italic,
      fontSize: 16,
    ) ?? const TextStyle(
      color: Colors.grey,
      fontStyle: FontStyle.italic,
      fontSize: 16,
    );
  }

  static TextStyle getLabelStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.textTheme.titleMedium?.copyWith(
      color: isDark ? lightBlue : darkPurple,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ) ?? const TextStyle(
      color: darkPurple,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );
  }

  static TextStyle getInputTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.textTheme.bodyLarge?.copyWith(
      color: isDark ? lightPink : Colors.black87,
      fontSize: 16,
    ) ?? const TextStyle(
      color: Colors.black87,
      fontSize: 16,
    );
  }

  static BoxDecoration getGradientDecoration(int currentStep, int totalSteps) {
    double factor = currentStep / (totalSteps - 1);
    final startColor = Color.lerp(lightPink, lightBlue, factor) ?? lightPink;
    final endColor = Color.lerp(lightBlue, lightPurple, factor) ?? lightPurple;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [startColor, endColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}