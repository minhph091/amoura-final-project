// lib/presentation/auth/login/login_viewmodel.dart

import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  // Trạng thái form
  final formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  // Hàm gọi khi nhấn nút login (chỉ validate form)
  void onLoginPressed() {
    if (formKey.currentState?.validate() ?? false) {
      // Để backend xử lý submit
    }
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}