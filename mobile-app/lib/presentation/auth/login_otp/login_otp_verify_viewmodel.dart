// lib/presentation/auth/login_otp/login_otp_verify_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/remote/auth_service.dart';

class LoginOtpVerifyViewModel extends ChangeNotifier {
  List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;
  final String email;

  bool isLoading = false;

  final AuthService _authService = AuthService();

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
      final response = await _authService.login(
        email: email,
        phoneNumber: '',
        password: null,
        otpCode: otp.trim(),
        loginType: 'EMAIL_OTP',
      );

      if (response['accessToken'] != null && response['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', response['accessToken']);
        await prefs.setString('refreshToken', response['refreshToken'] ?? '');
        onSuccess();
      } else {
        throw ApiException(response['message'] ?? 'Invalid or expired OTP');
      }
    } on ApiException catch (e) {
      final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Invalid or expired OTP';
      onError(errorMsg.isNotEmpty ? errorMsg : 'Invalid or expired OTP');
    } catch (e) {
      onError('Invalid or expired OTP');
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
      final response = await _authService.requestLoginOtp(email: email);
      if (response['message'] == 'If your email is registered, an OTP has been sent.') {
        // Không cần thông báo thành công, để UI hiển thị thông báo mặc định
      } else {
        throw ApiException(response['message'] ?? 'Failed to resend OTP');
      }
    } on ApiException catch (e) {
      final errorMsg = e.message.split('message: ')[1]?.split(',')[0] ?? 'Failed to resend OTP. Please try again.';
      onError(errorMsg.isNotEmpty ? errorMsg : 'Failed to resend OTP. Please try again.');
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