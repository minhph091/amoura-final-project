// lib/presentation/auth/login_otp/login_otp_viewmodel.dart
import 'package:flutter/material.dart';
import '../../../core/api/api_exception.dart';
import '../../../data/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

class LoginOtpViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  AnimationController? animController;

  final AuthRepository _authRepository = GetIt.I<AuthRepository>();

  void initAnimation(TickerProvider vsync) {
    animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  Future<void> onSendOtp({
    required void Function(String email) onSuccess,
  }) async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      try {
        final email = emailController.text.trim();
        final isAvailable = await _authRepository.checkEmailAvailability(email);
        if (isAvailable) {
          errorMessage = 'This email is not registered';
          isLoading = false;
          notifyListeners();
          return;
        }
        final response = await _authRepository.requestLoginOtp(email: email);
        if (response['message'] == 'If your email is registered, an OTP has been sent.') {
          onSuccess(email);
        } else {
          throw ApiException(response['message'] ?? 'Failed to send OTP');
        }
      } on ApiException catch (e) {
        errorMessage = e.message;
      } catch (e) {
        errorMessage = 'Failed to send OTP. Please try again.';
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    animController?.dispose();
    super.dispose();
  }
}