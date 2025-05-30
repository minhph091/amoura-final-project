// lib/presentation/auth/login_otp/login_otp_verify_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/usecases/auth/login_usecase.dart';

class LoginOtpVerifyViewModel extends ChangeNotifier {
List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;
  final String email;
  bool isLoading = false;
  final LoginUseCase _loginUseCase = GetIt.I<LoginUseCase>();

LoginOtpVerifyViewModel({this.otpLength = 6, required this.email})
      : otpControllers = List.generate(6, (_) => TextEditingController()),
        otpFocusNodes = List.generate(6, (_) => FocusNode());

  Future<void> onVerifyOtp({
    required void Function() onSuccess,
    required void Function(String error) onError,
    required String otp,
  }) async {
    if (otp.length != 6) {
      onError('Please enter a 6-digit OTP');
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await _loginUseCase.execute(
        email: email,
        phoneNumber: '',
        password: null,
        otpCode: otp.trim(),
        loginType: 'EMAIL_OTP',
      );

      if (response['accessToken'] != null && response['user'] != null) {
        onSuccess();
      } else {
        throw Exception('Invalid OTP, please check again');
      }
    } catch (e) {
      onError('Invalid OTP please check again');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendOtp({
    required void Function(String error) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _loginUseCase.requestLoginOtp(email: email);
      if (response['message'] != 'Email does not exist, please check again') {
        throw Exception('Failed to resend OTP');
      }
    } catch (e) {
      onError('Failed to resend OTP. Please try again.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}