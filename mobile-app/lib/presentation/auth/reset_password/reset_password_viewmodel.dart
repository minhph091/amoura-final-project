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
  bool isLoading = false;
  String? errorMessage;
  String? _storedOtp;

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
        errorMessage = 'This email is not registered';
        isLoading = false;
        notifyListeners();
        return;
      }
      await _authRepository.requestPasswordReset(email: email);
      sentEmail = email;
      hasSentEmail = true;
    } catch (e) {
      errorMessage = 'Could not send password reset request. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onVerifyOtp(String otp) {
    if (otp.length != otpLength) {
      errorMessage = 'Please enter a valid OTP';
      notifyListeners();
      return;
    }
    _storedOtp = otp;
    hasVerifiedOtp = true;
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> resetPassword(String newPassword) async {
    if (sentEmail == null || _storedOtp == null) {
      errorMessage = 'Invalid state. Please start over.';
      notifyListeners();
      return false;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.resetPassword(
        email: sentEmail!,
        otpCode: _storedOtp!,
        newPassword: newPassword,
      );
      errorMessage = 'Password reset successfully';
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to reset password. Please try again.';
      hasVerifiedOtp = false;
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendOtp() async {
    if (sentEmail != null) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      try {
        await _authRepository.requestPasswordReset(email: sentEmail!);
        errorMessage = 'A new OTP has been sent to your email';
      } catch (e) {
        errorMessage = 'Could not resend OTP. Please try again.';
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