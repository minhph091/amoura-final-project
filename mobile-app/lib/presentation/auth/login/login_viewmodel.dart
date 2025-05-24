// lib/presentation/auth/login/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Thêm import
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/remote/auth_service.dart';
import '../../../core/utils/validation_util.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController animController;

  bool isLoading = false;
  bool obscurePassword = true;

  final AuthService _authService = AuthService();

  LoginViewModel() {
    animController = AnimationController(
      vsync: const _EmptyTickerProvider(),
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> onLoginPressed({
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      notifyListeners();

      try {
        final account = accountController.text.trim();
        final password = passwordController.text;

        final loginType = ValidationUtil.isEmail(account) ? 'EMAIL_PASSWORD' : 'PHONE_PASSWORD';
        final email = ValidationUtil.isEmail(account) ? account : '';
        final phoneNumber = ValidationUtil.isPhoneNumber(account) ? account : '';

        final response = await _authService.login(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          loginType: loginType,
          otpCode: null,
        );

        if (response['accessToken'] != null && response['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', response['accessToken']);
          await prefs.setString('refreshToken', response['refreshToken'] ?? '');
          onSuccess?.call();
        } else {
          throw ApiException(response['message'] ?? 'Invalid email/phone or password');
        }
      } on ApiException catch (e) {
        final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Invalid email/phone or password';
        onError?.call(errorMsg.isNotEmpty ? errorMsg : 'Invalid email/phone or password');
      } catch (e) {
        onError?.call('Invalid email/phone or password');
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
    animController.dispose();
    super.dispose();
  }
}

class _EmptyTickerProvider implements TickerProvider {
  const _EmptyTickerProvider();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}