// lib/presentation/auth/login_otp/login_otp_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../data/remote/auth_service.dart';

class LoginOtpViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> onSendOtp({
    required void Function(String email) onSuccess,
    required void Function(String error) onError,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      notifyListeners();

      try {
        final email = emailController.text.trim();
        final response = await _authService.requestLoginOtp(email: email);

        if (response['message'] == 'If your email is registered, an OTP has been sent.') {
          onSuccess(email);
        } else {
          throw ApiException(response['message'] ?? 'Failed to send OTP');
        }
      } on ApiException catch (e) {
        onError(e.message);
      } catch (e) {
        onError('Failed to send OTP. Please try again.');
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}