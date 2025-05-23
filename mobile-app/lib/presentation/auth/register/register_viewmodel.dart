// lib/auth/register/register_viewmodel.dart

import 'package:flutter/material.dart';
import '../../../data/remote/register_api.dart';
import '../../../core/api/api_client.dart';

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

  final RegisterApi _registerApi = RegisterApi(ApiClient());

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  Future<void> initiateRegistration() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      try {
        final response = await _registerApi.initiateRegistration(
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          password: passwordController.text,
        );
        if (response['status'] == 'INITIATED') {
          sessionToken = response['sessionToken'];
          showOtp = true;
          errorMessage = null;
          notifyListeners();
        } else {
          throw Exception(response['message'] ?? 'Registration failed');
        }
      } catch (e) {
        errorMessage = 'Failed to initiate registration: $e';
        notifyListeners();
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> verifyOtp(BuildContext context, String otp) async {
    if (sessionToken == null) {
      errorMessage = 'Session token is missing. Please try registering again.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _registerApi.verifyOtp(
        sessionToken: sessionToken!,
        otpCode: otp,
      );
      if (response['status'] == 'VERIFIED') {
        showOtp = false;
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/setup-profile');
      } else {
        throw Exception(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      errorMessage = 'Invalid or expired OTP. Please try again.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}