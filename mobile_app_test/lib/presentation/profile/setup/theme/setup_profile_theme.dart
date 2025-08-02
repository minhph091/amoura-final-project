// lib/presentation/profile/setup/theme/setup_profile_theme.dart
import 'package:flutter/material.dart';

class ProfileTheme {
  // Main colors - matching the setup profile theme
  static const Color darkPink = Color(0xFFD81B60);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPink = Color(0xFFF48FB1);
  static const Color lightPurple = Color(0xFFCE93D8);

  // Get styles for different text elements
  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: darkPurple,
    );
  }

  static TextStyle getSubtitleStyle(BuildContext context) {
    return TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      color: darkPurple,
    );
  }

  static TextStyle getDescriptionStyle(BuildContext context) {
    return TextStyle(
      fontSize: 14.0,
      color: Colors.black87,
    );
  }

  static TextStyle getLabelStyle(BuildContext context) {
    return TextStyle(
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
      color: darkPurple,
    );
  }

  static TextStyle getInputTextStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    );
  }
}
