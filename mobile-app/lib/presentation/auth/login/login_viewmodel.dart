// lib/presentation/auth/login/login_viewmodel.dart

import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void onLoginPressed(void Function()? onSuccess, void Function(String error)? onError) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      notifyListeners();
      // Xử lý call API login ở đây (để backend code)
      await Future.delayed(const Duration(seconds: 1));
      // onSuccess?.call();
      // onError?.call("Sai tài khoản/mật khẩu");
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}