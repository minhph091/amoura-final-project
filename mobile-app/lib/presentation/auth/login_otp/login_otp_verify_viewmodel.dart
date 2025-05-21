// lib/presentation/auth/login_otp/login_otp_verify_viewmodel.dart

import 'package:flutter/material.dart';

class LoginOtpVerifyViewModel extends ChangeNotifier {
  List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;

  LoginOtpVerifyViewModel({this.otpLength = 6})
      : otpControllers = List.generate(6, (_) => TextEditingController()),
        otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  // Xử lý khi nhấn nút xác nhận OTP
  void onVerifyOtp() {
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length == otpLength) {
      // Để backend xử lý xác thực OTP
    }
  }

  @override
  void dispose() {
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}