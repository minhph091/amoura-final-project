// lib/presentation/auth/reset_password/reset_password_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/remote/auth_service.dart';

class ResetPasswordViewmodel extends ChangeNotifier {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hasSentEmail = false;
  bool hasVerifiedOtp = false;
  String? sentEmail;
  bool isLoading = false;
  String? errorMessage;

  final int otpLength;
  String _otp = '';

  // Thêm các biến để quản lý timer
  int remainingSeconds = 0;
  bool canResend = false;
  Timer? _timer;

  final AuthService _authService = AuthService();

  ResetPasswordViewmodel({this.otpLength = 6}) {
    startResendTimer(60); // Khởi tạo timer ngay khi khởi tạo ViewModel
  }

  Future<void> onSendEmail(String email) async {
    if (emailFormKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        sentEmail = email.trim();
        final response = await _authService.requestLoginOtp(email: sentEmail!);
        if (response['message'] == 'If your email is registered, an OTP has been sent.') {
          hasSentEmail = true;
          startResendTimer(60); // Reset timer khi gửi OTP
        } else {
          throw ApiException(response['message'] ?? 'Cannot send reset code');
        }
      } on ApiException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = 'Cannot send reset code. Please try again.';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void onOtpChanged(String otp) {
    _otp = otp;
    notifyListeners();
  }

  Future<void> onVerifyOtp(String otp) async {
    if (otp.length == otpLength) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final response = await _authService.login(
          email: sentEmail!,
          phoneNumber: '',
          password: null,
          otpCode: otp.trim(),
          loginType: 'EMAIL_OTP',
        );
        if (response['accessToken'] != null) {
          hasVerifiedOtp = true;
        } else {
          throw ApiException(response['message'] ?? 'Invalid OTP');
        }
      } on ApiException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = 'Invalid OTP. Please try again.';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> onResetPassword(String email, String password) async {
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = "Passwords do not match";
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // Placeholder for API call to reset password
      // Example: await _authService.resetPassword(email, password);
      // Assume success for now
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Reset password failed. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendOtp() async {
    if (!canResend || sentEmail == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.requestLoginOtp(email: sentEmail!);
      if (response['message'] == 'If your email is registered, an OTP has been sent.') {
        errorMessage = 'Resent OTP. Please check your email.';
        startResendTimer(60); // Reset timer khi resend
      } else {
        throw ApiException(response['message'] ?? 'Cannot resend OTP');
      }
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Cannot resend OTP. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Thêm logic quản lý timer
  void startResendTimer(int seconds) {
    remainingSeconds = seconds;
    canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        canResend = true;
        notifyListeners();
      }
    });
  }

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
    _timer?.cancel(); // Hủy timer khi dispose
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}