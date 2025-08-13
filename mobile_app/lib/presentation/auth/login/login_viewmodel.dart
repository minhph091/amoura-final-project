// lib/presentation/auth/login/login_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../core/utils/validation_util.dart';

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  AnimationController? animController;

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  final LoginUseCase _loginUseCase = GetIt.I<LoginUseCase>();

  void initAnimation(TickerProvider vsync) {
    animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> onLoginPressed({void Function()? onSuccess}) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final account = accountController.text.trim();
        final password = passwordController.text;

        final loginType =
            ValidationUtil.isEmail(account)
                ? 'EMAIL_PASSWORD'
                : 'PHONE_PASSWORD';
        final email = ValidationUtil.isEmail(account) ? account : '';
        final phoneNumber =
            ValidationUtil.isPhoneNumber(account) ? account : '';

        final response = await _loginUseCase.execute(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          loginType: loginType,
          otpCode: null,
        );

        debugPrint('API Response: $response');
        if (response['accessToken'] != null && response['user'] != null) {
          onSuccess?.call();
        } else {
          throw Exception('Login failed');
        }
      } catch (e) {
        errorMessage = 'Email/Phone or password is incorrect';
        debugPrint('Login error: $e');
        notifyListeners();
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
    animController?.dispose();
    super.dispose();
  }
}
