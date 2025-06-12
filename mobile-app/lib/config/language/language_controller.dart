import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageController() {
    _loadSavedLocale();
  }

  // Load the saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    final savedLocale = await AppLocalizations.getLocale();
    _locale = savedLocale;
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await AppLocalizations.setLocale(languageCode);
    notifyListeners();
  }

  // Get language name
  String getLanguageName(String languageCode) {
    final Map<String, String> names = {
      'en': 'English',
      'vi': 'Tiếng Việt',
    };
    return names[languageCode] ?? 'Unknown';
  }

  // Get all available languages
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': 'assets/icons/flag_en.png'},
      {'code': 'vi', 'name': 'Tiếng Việt', 'flag': 'assets/icons/flag_vi.png'},
    ];
  }
}
