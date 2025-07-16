import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_icons/country_icons.dart';
import 'app_localization_delegate.dart';
import 'translations/translations.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  // Load JSON language file from the "lang" folder
  Future<bool> load() async {
    try {
      Map<String, dynamic> jsonMap =
          supportedLanguages[locale.languageCode] ?? {};
      _localizedStrings = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );
      // print(
      //   '✅ AppLocalizations: Loaded ${_localizedStrings.length} translations for ${locale.languageCode}',
      // );
      // print(
      //   '✅ AppLocalizations: Sample sign_in = ${_localizedStrings['sign_in']}',
      // );
      return true;
    } catch (e) {
      // print('❌ AppLocalizations: Error loading translations: $e');
      return false;
    }
  }

  // Method to retrieve localized strings
  String translate(String key) {
    final result = _localizedStrings[key] ?? key;
    if (result == key && _localizedStrings.isNotEmpty) {
      // print(
      //   '⚠️ AppLocalizations: Missing translation for key: $key in ${locale.languageCode}',
      // );
    }
    return result;
  }

  // Language code for the selected locale
  String get languageCode => locale.languageCode;

  // Method to get all supported locales
  static List<Locale> get supportedLocales {
    return supportedLanguages.keys.map((code) => Locale(code)).toList();
  }

  // Method to get the language name for a locale
  static String getLanguageName(Locale locale) {
    final Map<String, String> names = {'en': 'English', 'vi': 'Tiếng Việt'};
    return names[locale.languageCode] ?? 'Unknown';
  }

  // Method to get the flag widget for a locale using country_icons library
  static Widget getLanguageFlag(String languageCode, {double size = 24}) {
    final Map<String, String> countryMapping = {
      'en': 'us', // English -> United States flag
      'vi': 'vn', // Vietnamese -> Vietnam flag
    };

    final countryCode = countryMapping[languageCode] ?? 'us';

    try {
      final flagWidget = CountryIcons.getSvgFlag(countryCode);
      return SizedBox(width: size, height: size, child: flagWidget);
    } catch (e) {
      // Fallback if flag loading fails
    }

    return Icon(Icons.language, size: size);
  }

  // Method to get flag as icon data (alternative approach)
  static Widget getLanguageFlagIcon(String languageCode, {double size = 24}) {
    final Map<String, IconData> flagIcons = {
      'en': Icons.flag, // Fallback to generic flag icon
      'vi': Icons.flag,
    };

    return Icon(flagIcons[languageCode] ?? Icons.language, size: size);
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
