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
        final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Email or phone number already registered';
        errorMessage = errorMsg.isNotEmpty ? errorMsg : 'Failed to register. Please try again.';
        notifyListeners();
      } catch (e) {
        errorMessage = 'Failed to register. Please try again.';
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
        Navigator.pushReplacementNamed(
          context,
          '/setup-profile',
          arguments: {'sessionToken': sessionToken},
        );
      } else {
        throw ApiException(response['message'] ?? 'Invalid or expired OTP');
      }
    } on ApiException catch (e) {
      final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Invalid or expired OTP';
      errorMessage = errorMsg.isNotEmpty ? errorMsg : 'Invalid or expired OTP';
      notifyListeners();
    } catch (e) {
      errorMessage = 'Invalid or expired OTP';
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
      errorMessage = 'A new OTP has been sent to your email'; // Thông báo bằng tiếng Anh
      startResendTimer(60); // Đặt lại timer 60 giây
      notifyListeners();
    } on ApiException catch (e) {
      final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Failed to resend OTP. Please try again.';
      errorMessage = errorMsg.isNotEmpty ? errorMsg : 'Failed to resend OTP. Please try again.';
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
        notifyListeners();
      } else {
        timer.cancel();
        canResend = true;
        notifyListeners();
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