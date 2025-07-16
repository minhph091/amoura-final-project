// If this file doesn't exist yet in your shared folder, you'll need to copy it from your setup folder
import 'package:flutter/material.dart';

class SetupProfileTheme {
  static const Color darkPink = Color(0xFFD81B60);
  static const Color darkPurple = Color(0xFF7B1FA2);

  static TextStyle getTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ) ?? const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
  }

  static TextStyle getDescriptionStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.black54,
    ) ?? const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    );
  }

  static TextStyle getLabelStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Colors.black87,
    ) ?? const TextStyle(
      fontSize: 16,
      color: Colors.black87,
    );
  }

  static TextStyle getInputTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: Colors.black,
    ) ?? const TextStyle(
      fontSize: 16,
      color: Colors.black,
    );
  }

  static BoxDecoration getGradientDecoration(int currentStep, int totalSteps) {
    // Calculate progress percentage
    final progress = currentStep / totalSteps;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFE91E63).withValues(alpha: 0.8),
          const Color(0xFF9C27B0).withValues(alpha: 0.9),
        ],
        stops: [progress * 0.5, 0.8 + (progress * 0.2)],
      ),
    );
  }
}
