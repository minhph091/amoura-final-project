// lib/presentation/auth/reset_password/reset_password_viewmodel.dart

import 'package:flutter/material.dart';

// ViewModel for the forgot password flow that manages state and business logic
class ResetPasswordViewmodel extends ChangeNotifier {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Form state
  bool hasSentEmail = false;
  bool hasVerifiedOtp = false;
  String? sentEmail;
  bool isLoading = false;
  String? errorMessage;

  // OTP handling
  final int otpLength;
  String _otp = '';

  ResetPasswordViewmodel({this.otpLength = 6});

  // Handle sending email for password reset
  void onSendEmail() async {
    if (emailFormKey.currentState?.validate() ?? false) {
      sentEmail = emailController.text.trim();
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // API call would happen here
      // The API would handle setting hasSentEmail = true when successful

      // For now, just end loading state without changing screens:
      isLoading = false;
      notifyListeners();
    }
  }

  // Update OTP value as user types
  void onOtpChanged(String otp) {
    _otp = otp;
    notifyListeners();
  }

  // Verify OTP code entered by user
  void onVerifyOtp() async {
    if (_otp.length == otpLength) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // API call would happen here
      // The API would handle setting hasVerifiedOtp = true when successful

      // For now, just end loading state without changing screens:
      isLoading = false;
      notifyListeners();
    }
  }

  // Handle password reset submission
  void onResetPassword() async {
    // Validate password match
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = "Passwords do not match";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // API call would happen here
    // The API would handle navigation on success

    // For now, just end loading state without navigating:
    isLoading = false;
    notifyListeners();
  }

  // Request a new OTP code
  void onResendOtp() async {
    if (sentEmail != null) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // API call would happen here

      isLoading = false;
      notifyListeners();
    }
  }

  // Reset all form state
  void reset() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    hasSentEmail = false;
    hasVerifiedOtp = false;
    sentEmail = null;
    errorMessage = null;
    _otp = '';
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}