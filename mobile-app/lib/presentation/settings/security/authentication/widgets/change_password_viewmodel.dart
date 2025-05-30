import 'package:flutter/material.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? currentPasswordError;
  String? newPasswordError;
  String? confirmPasswordError;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void validateInputs() {
    currentPasswordError = currentPasswordController.text.isEmpty ? 'Current password is required' : null;
    newPasswordError = newPasswordController.text.isEmpty ? 'New password is required' : null;
    confirmPasswordError = confirmPasswordController.text.isEmpty
        ? 'Confirm password is required'
        : newPasswordController.text != confirmPasswordController.text
        ? 'Passwords do not match'
        : null;

    notifyListeners();
  }

  void clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    currentPasswordError = null;
    newPasswordError = null;
    confirmPasswordError = null;
    notifyListeners();
  }

  void submit(BuildContext context) {
    validateInputs();
    if (currentPasswordError == null && newPasswordError == null && confirmPasswordError == null) {
      setLoading(true);
      // Placeholder cho logic backend
      Future.delayed(const Duration(seconds: 2), () {
        setLoading(false);
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}