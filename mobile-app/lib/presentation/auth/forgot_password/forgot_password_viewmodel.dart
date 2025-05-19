// lib/presentation/auth/forgot_password/forgot_password_viewmodel.dart

import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  // OTP
  List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;

  bool hasSentEmail = false;
  String? sentEmail;

  ForgotPasswordViewModel({this.otpLength = 6})
      : otpControllers = List.generate(6, (_) => TextEditingController()),
        otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Gửi email lấy mã
  void onSendEmail() {
    if (emailFormKey.currentState?.validate() ?? false) {
      sentEmail = emailController.text.trim();
      hasSentEmail = true;
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
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}