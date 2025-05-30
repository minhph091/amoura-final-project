// lib/presentation/auth/register/register_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/register_usecase.dart';

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

  final RegisterUseCase _registerUseCase = GetIt.I<RegisterUseCase>();

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
        final response = await _registerUseCase.initiate(
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          password: passwordController.text,
        );
        sessionToken = response['sessionToken'];
        showOtp = true;
        errorMessage = null;
        startResendTimer(60);
        notifyListeners();
      } catch (e) {
        errorMessage = e.toString().contains('already registered')
            ? 'Email or phone number already registered'
            : 'Failed to register. Please try again.';
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
      final response = await _registerUseCase.verifyOtp(
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
        throw Exception('Invalid OTP please check again');
      }
    } catch (e) {
      errorMessage = 'Invalid OTP please check again';
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
      await _registerUseCase.resendOtp(sessionToken: sessionToken!);
      errorMessage = 'A new OTP has been sent to your email';
      startResendTimer(60);
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