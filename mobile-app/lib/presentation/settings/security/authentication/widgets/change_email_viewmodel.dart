import 'package:flutter/material.dart';
import '../../../../../core/utils/validation_util.dart';

enum ChangeEmailStage {
  enterPassword,
  enterNewEmail,
  enterOtp
}

class ChangeEmailViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Form Keys
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();

  // Error messages
  String? _passwordError;
  String? _emailError;
  String? _otpError;

  String? get passwordError => _passwordError;
  String? get emailError => _emailError;
  String? get otpError => _otpError;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Current stage of the process
  ChangeEmailStage _currentStage = ChangeEmailStage.enterPassword;
  ChangeEmailStage get currentStage => _currentStage;

  // Timer for OTP resend
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  bool get canResend => _remainingSeconds <= 0;

  // Hàm xác thực mật khẩu để tiếp tục quá trình đổi email
  Future<void> verifyPassword(BuildContext context) async {
    if (passwordFormKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);

    try {
      // TODO: Kết nối API để xác thực mật khẩu (sẽ được code sau)
      await Future.delayed(const Duration(seconds: 1)); // Giả lập API call

      // Chuyển sang bước tiếp theo sau khi xác thực thành công
      _currentStage = ChangeEmailStage.enterNewEmail;
      _passwordError = null;
      notifyListeners();
    } catch (e) {
      _passwordError = "Incorrect password. Please try again.";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Gửi email mới để nhận OTP
  Future<void> requestEmailChange(BuildContext context) async {
    if (emailFormKey.currentState?.validate() != true) {
      return;
    }

    _setLoading(true);

    try {
      // TODO: Kết nối API để gửi yêu cầu đổi email (sẽ được code sau)
      await Future.delayed(const Duration(seconds: 1)); // Giả lập API call

      // Nếu thành công, hiển thị form OTP
      _currentStage = ChangeEmailStage.enterOtp;
      _emailError = null;
      _startOtpTimer();

      notifyListeners();

      // Hiển thị thông báo gửi OTP thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP sent to your new email address. Please check and verify."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Xử lý lỗi
      _emailError = "Failed to send verification code. Please try again.";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Xác thực OTP và hoàn tất đổi email
  Future<void> verifyOtpAndChangeEmail(BuildContext context) async {
    final otp = otpController.text.trim();

    if (ValidationUtil.validateOtp(otp) != null) {
      _otpError = ValidationUtil.validateOtp(otp);
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      // TODO: Kết nối API để xác thực OTP và đổi email (sẽ được code sau)
      await Future.delayed(const Duration(seconds: 2)); // Giả lập API call

      // Reset các trạng thái
      _resetState();

      // Nếu thành công, hiển thị thông báo và quay về
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email changed successfully!"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );

        // Quay về màn hình trước đó
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Xử lý lỗi
      _otpError = "Invalid OTP. Please check and try again.";
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP
  Future<void> resendOtp(BuildContext context) async {
    if (!canResend) return;

    _setLoading(true);

    try {
      // TODO: Gửi lại OTP qua API (sẽ được code sau)
      await Future.delayed(const Duration(seconds: 1)); // Giả lập API call

      _startOtpTimer();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP resent. Please check your email."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to resend OTP: ${e.toString()}"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  // Quay lại bước trước đó
  void goBack() {
    if (_currentStage == ChangeEmailStage.enterOtp) {
      _currentStage = ChangeEmailStage.enterNewEmail;
      otpController.clear();
      _otpError = null;
    } else if (_currentStage == ChangeEmailStage.enterNewEmail) {
      _currentStage = ChangeEmailStage.enterPassword;
      emailController.clear();
      _emailError = null;
    }
    notifyListeners();
  }

  // Bắt đầu đếm ngược thời gian để gửi lại OTP
  void _startOtpTimer() {
    _remainingSeconds = 60; // 60 giây trước khi có thể gửi lại
    notifyListeners();

    // Bắt đầu đếm ngược
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_remainingSeconds <= 0) return false;
      _remainingSeconds--;
      notifyListeners();
      return true;
    });
  }

  // Reset state về ban đầu
  void _resetState() {
    _currentStage = ChangeEmailStage.enterPassword;
    passwordController.clear();
    emailController.clear();
    otpController.clear();
    _passwordError = null;
    _emailError = null;
    _otpError = null;
    _remainingSeconds = 0;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    passwordController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
