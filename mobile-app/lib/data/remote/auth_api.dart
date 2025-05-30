import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/constants/api_endpoints.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi(this._apiClient);

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.refreshToken,
        data: refreshToken, // Gửi dưới dạng chuỗi thô thay vì JSON
      );
      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] == null) {
        throw ApiException(data['message'] ?? 'Refresh token failed');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.logout,
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> initiateRegistration({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.initiateRegistration,
        data: {
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'INITIATED') {
        throw ApiException(data['message'] ?? 'Could not initiate registration');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionToken,
    required String otpCode,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {
          'sessionToken': sessionToken,
          'otpCode': otpCode,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'VERIFIED') {
        throw ApiException(data['message'] ?? 'Invalid OTP code');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
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
        ApiEndpoints.completeRegistration,
        data: {
          'sessionToken': sessionToken,
          'firstName': firstName,
          'lastName': lastName,
          'dateOfBirth': dateOfBirth,
          'sex': sex,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'COMPLETED') {
        throw ApiException(data['message'] ?? 'Không thể hoàn tất đăng ký');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> resendOtp({required String sessionToken}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resendOtp,
        data: {'sessionToken': sessionToken},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not resend OTP');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
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
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'phoneNumber': phoneNumber ?? '',
          'password': password,
          'otpCode': otpCode?.trim(),
          'loginType': loginType,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['accessToken'] == null || data['user'] == null) {
        throw ApiException(data['message'] ?? 'Login failed');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> requestLoginOtp({required String email}) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.requestLoginOtp}?email=$email',
        data: {},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not send OTP');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<bool> checkEmailAvailability(String email) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.checkEmailAvailability,
        queryParameters: {'email': email},
      );
      return response.data as bool;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.requestPasswordReset,
        data: {'email': email},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not send password reset OTP');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'otpCode': otpCode,
          'newPassword': newPassword,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['message'] == null) {
        throw ApiException('Could not reset password');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String sessionToken,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.updateProfile,
        data: {
          'sessionToken': sessionToken,
          ...profileData,
        },
      );
      final data = response.data as Map<String, dynamic>;
      if (data['status'] != 'UPDATED') {
        throw ApiException(data['message'] ?? 'Could not update profile');
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data as Map<String, dynamic>?;
      final message = data?['message'] ?? 'Unknown error';
      if (message.contains('Invalid OTP') || message.contains('expired')) {
        return 'Invalid or expired OTP';
      } else if (message.contains('not found') || message.contains('not registered')) {
        return 'This email is not registered';
      }
      return message;
    }
    return 'Network error. Please check your connection and try again.';
  }
}