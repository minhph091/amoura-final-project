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
}
