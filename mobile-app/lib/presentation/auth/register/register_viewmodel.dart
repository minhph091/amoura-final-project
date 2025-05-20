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
  String? sessionToken; // Thêm để lưu sessionToken từ API

  // OTP
  List<TextEditingController> otpControllers;
  List<FocusNode> otpFocusNodes;
  final int otpLength;

  final RegisterApi _registerApi;

  RegisterViewModel({this.otpLength = 6})
      : _registerApi = RegisterApi(ApiClient()),
        otpControllers = List.generate(6, (_) => TextEditingController()),
        otpFocusNodes = List.generate(6, (_) => FocusNode());

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  // Khởi tạo đăng ký
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
          sessionToken = response['sessionToken']; // Lưu sessionToken
          showOtp = true; // Chuyển sang giao diện OTP
        } else {
          throw Exception(response['message'] ?? 'Registration failed');
        }
      } catch (e) {
        if (e.toString().contains('REGISTRATION_IN_PROGRESS')) {
          errorMessage = 'A registration is already in progress. Please check your email for the OTP or try again later.';
        } else if (e.toString().contains('EMAIL_ALREADY_EXISTS')) {
          errorMessage = 'This email is already registered. Please use a different email.';
        } else {
          errorMessage = 'Failed to initiate registration: $e';
        }
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    for (final ctl in otpControllers) {
      ctl.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}