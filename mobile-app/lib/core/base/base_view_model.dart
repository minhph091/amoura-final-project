// lib/core/base/base_view_model.dart

import 'package:flutter/material.dart';

/// Base cho ViewModel, kế thừa ChangeNotifier để sử dụng với Provider
class BaseViewModel extends ChangeNotifier {
  bool _loading = false;

  bool get isLoading => _loading;

  void setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}