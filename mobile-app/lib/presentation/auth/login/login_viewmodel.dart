// lib/presentation/auth/login/login_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../data/remote/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  final AuthService _authService = AuthService();

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> onLoginPressed(BuildContext context, String account, String password) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final response = await _authService.login(
          email: account.contains('@') ? account : '',
          phoneNumber: account.contains('@') ? '' : account,
          password: password,
          otpCode: null,
          loginType: 'EMAIL_PASSWORD',
        );

        if (response['accessToken'] != null && response['user'] != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          throw ApiException(response['message'] ?? 'Login failed');
        }
      } on ApiException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = 'Login failed. Please try again.';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    accountController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}