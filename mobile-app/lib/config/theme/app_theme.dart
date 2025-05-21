// lib/config/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

final String _bodyFontFamily = GoogleFonts.lato().fontFamily!;
final String _displayFontFamily = GoogleFonts.playfairDisplay().fontFamily!;

class AppTheme {
  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: _bodyFontFamily,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.background,
      onPrimary: Colors.white,
      onSurface: AppColors.text,
      onSecondary: AppColors.label,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.dancingScript(
        textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
      ),
      displayMedium: GoogleFonts.dancingScript(
        textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.text),
      ),
      bodyLarge: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, color: AppColors.text),
      ),
      bodyMedium: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, color: AppColors.text),
      ),
      labelLarge: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.label),
      ),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.text),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text),

    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.label),
      hintStyle: const TextStyle(color: AppColors.label),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: _bodyFontFamily,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkBackground,
      onPrimary: AppColors.darkText,
      onSurface: AppColors.darkText,
      onSecondary: AppColors.darkLabel,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.dancingScript(
        textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkText),
      ),
      displayMedium: GoogleFonts.dancingScript(
        textStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: AppColors.darkText),
      ),
      bodyLarge: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, color: AppColors.darkText),
      ),
      bodyMedium: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, color: AppColors.darkText),
      ),
      labelLarge: GoogleFonts.playfairDisplay(
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkLabel),
      ),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.darkText),
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkText),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.darkLabel),
      hintStyle: const TextStyle(color: AppColors.darkLabel),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkText,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );
}