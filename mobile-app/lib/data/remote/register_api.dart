import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class RegisterApi {
  final ApiClient _apiClient;

  RegisterApi(this._apiClient);

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
      print('API Response: ${response.data}'); // Thêm log để debug
      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('API Error: $e'); // Thêm log để debug
      throw ApiException('Failed to initiate registration: $e');
    }
  }
}