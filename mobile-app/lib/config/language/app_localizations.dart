import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localization_delegate.dart';
import 'supported_locales.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  // Load JSON language file from the "lang" folder
  Future<bool> load() async {
    Map<String, dynamic> jsonMap = supportedLanguages[locale.languageCode] ?? {};
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  // Method to retrieve localized strings
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Language code for the selected locale
  String get languageCode => locale.languageCode;

  // Method to get all supported locales
  static List<Locale> get supportedLocales {
    return supportedLanguages.keys.map((code) => Locale(code)).toList();
  }

  // Method to get the language name for a locale
  static String getLanguageName(Locale locale) {
    final Map<String, String> names = {
      'en': 'English',
      'vi': 'Tiếng Việt',
    };
    return names[locale.languageCode] ?? 'Unknown';
  }

  // Method to get the flag asset path for a locale
  static String getLanguageFlag(String languageCode) {
    final Map<String, String> flags = {
      'en': 'assets/icons/flag_en.png',
      'vi': 'assets/icons/flag_vi.png',
    };
    return flags[languageCode] ?? 'assets/icons/flag_placeholder.png';
  }

  // Method to save the selected locale to shared preferences
  static Future<void> setLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  // Method to get the selected locale from shared preferences
  static Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language_code') ?? 'en';
    return Locale(languageCode);
  }
}
