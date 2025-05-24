// lib/data/remote/auth_service.dart
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> initiateRegistration({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/initiate',
        data: {
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      print('Initiate Registration Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'INITIATED') {
        throw ApiException(data['message'] ?? 'Không thể khởi tạo đăng ký');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Initiate Registration Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Initiate Registration Error: $e');
      throw ApiException('Không thể khởi tạo đăng ký: $e');
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionToken,
    required String otpCode,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/verify-otp',
        data: {
          'sessionToken': sessionToken,
          'otpCode': otpCode,
        },
      );
      print('Verify OTP Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'VERIFIED') {
        throw ApiException(data['message'] ?? 'Mã OTP không đúng');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Verify OTP Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Verify OTP Error: $e');
      throw ApiException('Mã OTP không đúng: $e');
    }
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String sex,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/complete',
        data: {
          'sessionToken': sessionToken,
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'sex': sex,
        },
      );
      print('Complete Registration Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'COMPLETED') {
        throw ApiException(data['message'] ?? 'Không thể hoàn tất đăng ký');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Complete Registration Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Complete Registration Error: $e');
      throw ApiException('Không thể hoàn tất đăng ký: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    String? phoneNumber,
    String? password,
    String? otpCode,
    required String loginType,
  }) async {
    try {
      final body = {
        'email': email,
        'phoneNumber': phoneNumber ?? '',
        'password': password,
        'otpCode': otpCode?.trim(),
        'loginType': loginType,
      };
      print('Sending login request with body: $body');
      final response = await _apiClient.post(
        '/auth/login',
        data: body,
      );
      print('Login Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] == null || data['user'] == null) {
        throw ApiException(data['message'] ?? 'Đăng nhập thất bại');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Login Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Login Error: $e');
      throw ApiException('Đăng nhập thất bại: $e');
    }
  }

  Future<Map<String, dynamic>> resendOtp({required String sessionToken}) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/resend-otp',
        data: {'sessionToken': sessionToken},
      );
      print('Resend OTP Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Không thể gửi lại OTP');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Resend OTP Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Resend OTP Error: $e');
      throw ApiException('Không thể gửi lại OTP: $e');
    }
  }

  Future<Map<String, dynamic>> requestLoginOtp({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login/otp/request?email=$email',
        data: {},
      );
      print('Request Login OTP Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Không thể gửi OTP');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Request Login OTP Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Request Login OTP Error: $e');
      throw ApiException('Không thể gửi OTP: $e');
    }
  }

Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/password/reset/request',
        data: {'email': email},
      );
      print('Request Password Reset Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not send password reset OTP');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Request Password Reset Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Request Password Reset Error: $e');
      throw ApiException('Could not send password reset OTP: $e');
    }
  }

  Future<bool> verifyPasswordResetOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      // Gọi API reset password với một mật khẩu giả để kiểm tra OTP
      // Nếu OTP hợp lệ, API sẽ trả về thành công, nếu không sẽ throw lỗi
      await _apiClient.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': 'tempPassword123!', // Mật khẩu giả để kiểm tra OTP
        },
      );
      return true;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Verify Password Reset OTP Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Verify Password Reset OTP Error: $e');
      throw ApiException('Invalid OTP: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/password/reset',
        data: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
      );
      print('Reset Password Response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not reset password');
      }
      return data;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Reset Password Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Reset Password Error: $e');
      throw ApiException('Could not reset password: $e');
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data as Map<String, dynamic>?;
      final message = data?['message'] ?? 'Unknown error';
      if (message.contains('already exists')) {
        return 'Email or phone number already registered';
      } else if (message.contains('Invalid OTP') || message.contains('expired')) {
        return 'Invalid or expired OTP';
      } else if (message.contains('not found') || message.contains('not registered')) {
        return 'This email is not registered';
      } else if (message.contains('Invalid credentials') || message.contains('wrong password')) {
        return 'Incorrect email or password';
      }
      return message;
    }
    return 'Network error. Please check your connection and try again.';
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}