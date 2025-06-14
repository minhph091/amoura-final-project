import '../../core/api/api_client.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';

class UserApi {
  final ApiClient _apiClient;
  UserApi(this._apiClient);

  // PATCH /user
  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.patch(ApiEndpoints.user, data: userData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update user: \\${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error updating user: \\${e.message}');
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/user/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to change password');
      }
    } on DioException catch (e) {
      print('Error changing password: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to change password');
    } catch (e) {
      print('Unexpected error in changePassword: $e');
      throw Exception('Failed to change password: $e');
    }
  }

  // Gửi yêu cầu đổi email, trả về message hoặc lỗi
  Future<Map<String, dynamic>> requestEmailChange(String newEmail) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.changeEmailRequest,
        data: {'newEmail': newEmail},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to request email change');
      }
    } on DioException catch (e) {
      print('Error requesting email change: \\${e.response?.statusCode} - \\${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to request email change');
    } catch (e) {
      print('Unexpected error in requestEmailChange: $e');
      throw Exception('Failed to request email change: $e');
    }
  }

  // Xác nhận đổi email bằng OTP
  Future<void> confirmEmailChange(String otpCode) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.changeEmailConfirm,
        data: {'otpCode': otpCode},
      );
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to confirm email change');
      }
    } on DioException catch (e) {
      print('Error confirming email change: \\${e.response?.statusCode} - \\${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to confirm email change');
    } catch (e) {
      print('Unexpected error in confirmEmailChange: $e');
      throw Exception('Failed to confirm email change: $e');
    }
  }
}
