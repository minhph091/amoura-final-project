// lib/presentation/auth/forgot_password/forgot_password_viewmodel.dart

import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool hasSentEmail = false;
  String? sentEmail;
  bool isLoading = false;
  String? errorMessage;

  final int otpLength;
  String _otp = '';

  ForgotPasswordViewModel({this.otpLength = 6});

  void onSendEmail() async {
    if (emailFormKey.currentState?.validate() ?? false) {
      sentEmail = emailController.text.trim();
      hasSentEmail = true;
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      // Gọi backend gửi OTP (để backend code)
      // Khi xong:
      isLoading = false;
      notifyListeners();
    }
  }

  void onOtpChanged(String otp) {
    _otp = otp;
    notifyListeners();
  }

  void onVerifyOtp(void Function() onSuccess) async {
    if (_otp.length == otpLength) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      // Gọi backend xác thực OTP (để backend code)
      // Nếu thành công:
      onSuccess();
      // Nếu lỗi:
      // errorMessage = "Invalid OTP";
      isLoading = false;
      notifyListeners();
    }
  }

  void onResendOtp() async {
    if (sentEmail != null) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      // Gọi backend gửi lại OTP (để backend code)
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    emailController.clear();
    hasSentEmail = false;
    sentEmail = null;
    errorMessage = null;
    _otp = '';
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}