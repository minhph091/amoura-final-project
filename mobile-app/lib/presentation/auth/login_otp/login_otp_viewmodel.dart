// lib/presentation/auth/login_otp/login_otp_viewmodel.dart

import 'package:flutter/material.dart';

class LoginOtpViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;

  // Gọi khi ấn nút gửi OTP
  void onSendOtp() {
    if (formKey.currentState?.validate() ?? false) {
      // Để backend xử lý gửi OTP
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}