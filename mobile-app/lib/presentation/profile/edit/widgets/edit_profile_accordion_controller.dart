// lib/presentation/profile/edit/widgets/edit_profile_accordion_controller.dart

import 'package:flutter/material.dart';

class EditProfileAccordionController extends ChangeNotifier {
  String? _currentOpenKey;

  String? get currentOpenKey => _currentOpenKey;

  void toggle(String key) {
    if (_currentOpenKey == key) {
      _currentOpenKey = null;
    } else {
      _currentOpenKey = key;
    }
    notifyListeners();
  }
}