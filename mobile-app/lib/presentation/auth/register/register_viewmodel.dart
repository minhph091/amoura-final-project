// lib/presentation/auth/register/register_viewmodel.dart

import 'package:flutter/material.dart';

class RegisterViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool showOtp = false;
  bool isLoading = false;

  // OTP
  List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;

  RegisterViewModel({this.otpLength = 6})
      : otpControllers = List.generate(6, (_) => TextEditingController()),
        otpFocusNodes = List.generate(6, (_) => FocusNode());

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  // Khi nhấn nút đăng ký
  void onRegister() {
    if (formKey.currentState?.validate() ?? false) {
      showOtp = true;
      notifyListeners();
      // Để backend xử lý gửi OTP
    }
  }

  void onVerifyOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == otpLength) {
      // Để backend xác thực OTP
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}