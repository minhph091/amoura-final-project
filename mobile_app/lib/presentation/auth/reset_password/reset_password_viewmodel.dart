// lib/presentation/auth/reset_password/reset_password_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/repositories/auth_repository.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final emailFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hasSentEmail = false;
  bool hasVerifiedOtp = false;
  String? sentEmail;
  String? sessionToken;
  bool isLoading = false;
  String? errorMessage;

  final int otpLength;
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  ResetPasswordViewModel({this.otpLength = 6, String? email}) {
    if (email != null) {
      emailController.text = email;
    }
  }

  Future<void> onSendEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final isAvailable = await _authRepository.checkEmailAvailability(email);
      if (isAvailable) {
        errorMessage = 'Email does not exist, please check again';
        isLoading = false;
        notifyListeners();
        return;
      }
      final response = await _authRepository.requestPasswordReset(email: email);
      sentEmail = email;
      sessionToken = response['sessionToken'];
      hasSentEmail = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onVerifyOtp(String otp) async {
    if (otp.length != otpLength) {
      errorMessage = 'Invalid OTP, please check again';
      notifyListeners();
      return;
    }
    
    if (sessionToken == null) {
      errorMessage = 'Invalid state. Please start over.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();
    
    try {
      await _authRepository.verifyPasswordResetOtp(
        sessionToken: sessionToken!,
        otpCode: otp,
      );
      hasVerifiedOtp = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    if (sessionToken == null) {
      errorMessage = 'Invalid state. Please start over.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.resetPassword(
        sessionToken: sessionToken!,
        newPassword: newPassword,
      );
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendOtp() async {
    if (sessionToken != null) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      try {
        await _authRepository.resendPasswordResetOtp(sessionToken: sessionToken!);
        errorMessage = 'A new OTP has been sent to your email';
      } catch (e) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
