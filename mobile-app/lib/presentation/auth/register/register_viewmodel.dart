// lib/presentation/auth/register/register_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/remote/auth_service.dart';

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
  String? errorMessage;
  String? sessionToken;

  int remainingSeconds = 0;
  bool canResend = false;
  Timer? _timer;

  final AuthService _authService = AuthService();

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  Future<void> initiateRegistration(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      try {
        final response = await _authService.initiateRegistration(
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          password: passwordController.text,
        );
        sessionToken = response['sessionToken'];
        showOtp = true;
        errorMessage = null;
        startResendTimer(60);
        notifyListeners();
      } on ApiException catch (e) {
        errorMessage = e.message.contains('already') ? 'Email or phone number already registered' : 'Registration failed. Please try again.';
        notifyListeners();
      } catch (e) {
        errorMessage = 'Registration failed. Please try again.';
        notifyListeners();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> verifyOtp(BuildContext context, String otp) async {
    if (sessionToken == null) {
      errorMessage = 'Invalid registration session. Please try again.';
      notifyListeners();
      return;
    }
    if (otp.length != 6) {
      errorMessage = 'Please enter a 6-digit OTP';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _authService.verifyOtp(
        sessionToken: sessionToken!,
        otpCode: otp,
      );
      if (response['status'] == 'VERIFIED') {
        showOtp = false;
        notifyListeners();
        // Điều hướng đến Setup Profile với sessionToken
        Navigator.pushReplacementNamed(
          context,
          '/setup-profile',
          arguments: {'sessionToken': sessionToken},
        );
      } else {
        throw ApiException(response['message'] ?? 'Invalid OTP or expired');
      }
    } on ApiException catch (e) {
      errorMessage = e.message.contains('invalid') || e.message.contains('expired') ? 'Invalid OTP or expired' : 'OTP verification failed.';
      notifyListeners();
    } catch (e) {
      errorMessage = 'OTP verification failed. Please try again.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendOtp() async {
    if (!canResend || sessionToken == null) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _authService.resendOtp(sessionToken: sessionToken!);
      errorMessage = response['message'] == 'OTP resent' ? 'OTP resent successfully' : 'Failed to resend OTP. Please try again.';
      startResendTimer(response['nextResendAvailableInSeconds'] ?? 60);
      notifyListeners(); // Đảm bảo thông báo sau khi cập nhật timer
    } on ApiException catch (e) {
      errorMessage = 'Failed to resend OTP. Please try again.';
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to resend OTP. Please try again.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startResendTimer(int seconds) {
    remainingSeconds = seconds;
    canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners(); // Cập nhật mỗi giây
      } else {
        timer.cancel();
        canResend = true;
        notifyListeners(); // Cập nhật khi timer kết thúc
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}