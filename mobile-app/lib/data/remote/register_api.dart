import '../../core/api/api_client.dart';

class RegisterApi {
  final ApiClient _apiClient;

  RegisterApi(this._apiClient);

  // Phương thức khởi tạo đăng ký
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
      print('API Response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('API Error: $e');
      throw ApiException('Failed to initiate registration: $e');
    }
  }

  // Phương thức xác thực OTP
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
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Verify OTP Error: $e');
      throw ApiException('Failed to verify OTP: $e');
    }
  }

  // Phương thức hoàn tất đăng ký
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
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('Complete Registration Error: $e');
      throw ApiException('Failed to complete registration: $e');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}