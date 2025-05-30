// lib/presentation/profile/view/widgets/accordion_section_controller.dart

import 'package:flutter/material.dart';

class AccordionSectionController extends ChangeNotifier {
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