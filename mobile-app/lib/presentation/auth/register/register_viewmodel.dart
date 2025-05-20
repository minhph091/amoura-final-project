import 'package:flutter/material.dart';
import '../../../data/remote/register_api.dart';
import '../../../core/api/api_client.dart';

class RegisterViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  String? sex;

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool showOtp = false;
  bool showCompleteForm = false;
  bool showDateOfBirthForm = false;
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
          showCompleteForm = false;
          showDateOfBirthForm = false;
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

  Future<void> verifyOtp(String otp) async {
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
        showCompleteForm = true;
        showDateOfBirthForm = false;
      } else {
        throw Exception(response['message'] ?? 'OTP verification failed');
      }
    } catch (e) {
      errorMessage = 'Invalid or expired OTP. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeRegistration(BuildContext context) async {
    if (sessionToken == null) {
      errorMessage = 'Session token is missing. Please try registering again.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      // Chuyển định dạng dateOfBirth từ DD/MM/YYYY sang YYYY-MM-DD với hai chữ số
      String formattedDateOfBirth = '';
      if (dateOfBirthController.text.isNotEmpty) {
        final parts = dateOfBirthController.text.split('/');
        if (parts.length == 3) {
          final year = parts[2];
          final month = parts[1].padLeft(2, '0'); // Đảm bảo hai chữ số
          final day = parts[0].padLeft(2, '0');   // Đảm bảo hai chữ số
          formattedDateOfBirth = '$year-$month-$day'; // YYYY-MM-DD
        } else {
          throw Exception('Invalid date format. Please use DD/MM/YYYY.');
        }
      }

      // Chuẩn hóa giá trị sex để khớp với backend
      String formattedSex;
      switch (sex) {
        case 'Male':
          formattedSex = 'male';
          break;
        case 'Female':
          formattedSex = 'female';
          break;
        case 'Non-binary':
          formattedSex = 'other'; // Ánh xạ Non-binary thành 'other'
          break;
        case 'Prefer not to say':
          formattedSex = ''; // Gửi chuỗi rỗng nếu người dùng không muốn tiết lộ
          break;
        default:
          formattedSex = 'male'; // Giá trị mặc định
      }

      final response = await _registerApi.completeRegistration(
        sessionToken: sessionToken!,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: formattedDateOfBirth,
        sex: formattedSex,
      );
      if (response['status'] == 'COMPLETED') {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        throw Exception(response['message'] ?? 'Registration completion failed');
      }
    } catch (e) {
      errorMessage = 'Failed to complete registration: $e';
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
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }
}