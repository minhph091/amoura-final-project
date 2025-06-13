// lib/data/remote/profile_api.dart
import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';

class ProfileApi {
  final ApiClient _apiClient;

  ProfileApi(this._apiClient);

  // Fetch current user's profile from the backend API
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.updateProfile); // Endpoint: /profiles/me
      if (response.statusCode == 200) {
        // Add detailed logging for debugging
        print('API Response Data: ${response.data}');
        print('Body Type from API: ${response.data['bodyType']}');
        print('Height from API: ${response.data['height']}');
        
        if (response.data['bodyType'] == null || response.data['height'] == null) {
          print('Warning: Missing appearance data in API response');
        }
        
        return response.data as Map<String, dynamic>;
      } else {
        print('API Error Response: ${response.statusCode} - ${response.data}');
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Log error details for debugging
      print('Error fetching profile: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Error fetching profile: ${e.message}');
    } catch (e) {
      print('Unexpected error in getProfile: $e');
      throw Exception('Error fetching profile: $e');
    }
  }

  // Fetch current user's information from the /user API
  // Comment: This endpoint returns basic user information (firstName, lastName, username)
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _apiClient.get('/user'); // Endpoint: /user (corrected from /users)
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch user info: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching user info: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception('Error fetching user info: ${e.message}');
    } catch (e) {
      print('Unexpected error in getUserInfo: $e');
      throw Exception('Error fetching user info: $e');
    }
  }
}