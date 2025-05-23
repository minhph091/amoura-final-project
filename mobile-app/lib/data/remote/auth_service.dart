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

  Future<Map<String, dynamic>> updateProfileStep({
    required String sessionToken,
    required int step,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register/update-profile-step',
        data: {
          'sessionToken': sessionToken,
          'step': step,
          ...data,
        },
      );
      print('Update Profile Step Response: ${response.data}');
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['status'] != 'SUCCESS') {
        throw ApiException(responseData['message'] ?? 'Không thể cập nhật thông tin');
      }
      return responseData;
    } on DioException catch (e) {
      final errorMessage = _handleDioError(e);
      print('Update Profile Step Error: $errorMessage');
      throw ApiException(errorMessage);
    } catch (e) {
      print('Update Profile Step Error: $e');
      throw ApiException('Không thể cập nhật thông tin: $e');
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

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data as Map<String, dynamic>?;
      final message = data?['message'] ?? 'Lỗi không xác định';
      if (message.contains('already exists')) {
        return 'Email hoặc số điện thoại đã được đăng ký';
      } else if (message.contains('Invalid OTP') || message.contains('expired')) {
        return 'Mã OTP không đúng hoặc đã hết hạn';
      } else if (message.contains('not found') || message.contains('not registered')) {
        return 'Email này chưa được đăng ký';
      } else if (message.contains('Invalid credentials') || message.contains('wrong password')) {
        return 'Email hoặc mật khẩu không đúng';
      }
      return message;
    }
    return 'Lỗi kết nối mạng. Vui lòng kiểm tra và thử lại.';
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}