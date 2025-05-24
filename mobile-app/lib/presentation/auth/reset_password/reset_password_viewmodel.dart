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
  String? _storedOtp;

  final int otpLength;
  final AuthService _authService = AuthService();

  ResetPasswordViewmodel({this.otpLength = 6, String? email}) {
    if (email != null) {
      emailController.text = email;
    }
  }

  Future<void> onSendEmail(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _authService.requestPasswordReset(email: email);
      sentEmail = email;
      hasSentEmail = true;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Unable to send password reset request. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onVerifyOtp(String otp) {
    if (otp.length == otpLength) {
      _storedOtp = otp;
      hasVerifiedOtp = true;
      errorMessage = null;
      notifyListeners();
    } else {
      errorMessage = 'Please enter a valid OTP';
      notifyListeners();
    }
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
      await _authService.resetPassword(
        email: sentEmail!,
        otpCode: _storedOtp!,
        newPassword: newPassword,
      );
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      hasVerifiedOtp = false; // Quay lại bước nhập OTP
      return false;
    } catch (e) {
      errorMessage = 'Failed to reset password. Please try again.';
      hasVerifiedOtp = false; // Quay lại bước nhập OTP
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
        await _authService.requestPasswordReset(email: sentEmail!);
        errorMessage = 'A new OTP has been sent to your email';
      } on ApiException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = 'Unable to resend OTP. Please try again.';
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