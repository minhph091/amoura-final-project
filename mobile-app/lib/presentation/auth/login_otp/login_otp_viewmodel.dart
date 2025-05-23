// lib/presentation/auth/login_otp/login_otp_verify_viewmodel.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/remote/auth_service.dart';

class LoginOtpVerifyViewModel extends ChangeNotifier {
  final List<TextEditingController> otpControllers;
  final List<FocusNode> otpFocusNodes;
  final int otpLength;
  final String email;

  bool isLoading = false;
  String? errorMessage;

  int _remainingSeconds = 0;
  bool _canResend = false;
  Timer? _timer;

  final AuthService _authService = AuthService();

  LoginOtpVerifyViewModel({required this.otpLength, required this.email})
      : otpControllers = List.generate(otpLength, (_) => TextEditingController()),
        otpFocusNodes = List.generate(otpLength, (_) => FocusNode()) {
    startResendTimer(60); // Khởi tạo timer với 60 giây
  }

  int get remainingSeconds => _remainingSeconds;
  bool get canResend => _canResend;

  Future<void> onVerifyOtp(BuildContext context, String otp) async {
    if (otp.length != otpLength) {
      errorMessage = 'Vui lòng nhập đủ $otpLength chữ số OTP';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
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
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        throw ApiException(response['message'] ?? 'Đăng nhập thất bại');
      }
    } on ApiException catch (e) {
      errorMessage = _handleApiError(e.message);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onResendOtp() async {
    if (!_canResend) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.requestLoginOtp(email: email);
      if (response['message'] == 'If your email is registered, an OTP has been sent.') {
        errorMessage = 'Đã gửi lại OTP. Vui lòng kiểm tra email.';
        startResendTimer(60); // Reset timer
      } else {
        throw ApiException(response['message'] ?? 'Gửi lại OTP thất bại');
      }
    } on ApiException catch (e) {
      errorMessage = 'Gửi lại OTP thất bại. Vui lòng thử lại.';
      notifyListeners();
    } catch (e) {
      errorMessage = 'Gửi lại OTP thất bại. Vui lòng thử lại.';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startResendTimer(int seconds) {
    _remainingSeconds = seconds;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        _canResend = true;
        notifyListeners();
      }
    });
  }

  String _handleApiError(String message) {
    if (message.contains('Invalid OTP') || message.contains('expired')) {
      return 'Mã OTP không đúng hoặc đã hết hạn';
    } else if (message.contains('not found') || message.contains('not registered')) {
      return 'Email này chưa được đăng ký';
    }
    return 'Đăng nhập thất bại. Vui lòng thử lại.';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}