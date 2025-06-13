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

  // Lấy options cho profile từ API /profiles/options
  Future<Map<String, dynamic>> getProfileOptions() async {
    try {
      final response = await _apiClient.get('/profiles/options');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch profile options: \\${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error fetching profile options: \\${e.response?.statusCode} - \\${e.response?.data}');
      throw Exception('Error fetching profile options: \\${e.message}');
    } catch (e) {
      print('Unexpected error in getProfileOptions: $e');
      throw Exception('Error fetching profile options: $e');
    }
  }

  // Upload avatar
  Future<String> uploadAvatar(String filePath) async {
    try {
      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.uploadAvatar,
        fileField: 'file',
        filePath: filePath,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload avatar');
      }
    } on DioException catch (e) {
      print('Error uploading avatar: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to upload avatar');
    } catch (e) {
      print('Unexpected error in uploadAvatar: $e');
      throw Exception('Failed to upload avatar: $e');
    }
  }

  // Upload cover
  Future<String> uploadCover(String filePath) async {
    try {
      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.uploadCover,
        fileField: 'file',
        filePath: filePath,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload cover');
      }
    } on DioException catch (e) {
      print('Error uploading cover: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to upload cover');
    } catch (e) {
      print('Unexpected error in uploadCover: $e');
      throw Exception('Failed to upload cover: $e');
    }
  }

  // Upload highlight
  Future<String> uploadHighlight(String filePath) async {
    try {
      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.uploadHighlights,
        fileField: 'file',
        filePath: filePath,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['url'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to upload highlight');
      }
    } on DioException catch (e) {
      print('Error uploading highlight: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? 'Failed to upload highlight');
    } catch (e) {
      print('Unexpected error in uploadHighlight: $e');
      throw Exception('Failed to upload highlight: $e');
    }
  }

  Future<void> deleteAvatar() async {
    await _apiClient.dio.delete(ApiEndpoints.deleteAvatar);
  }

  Future<void> deleteCover() async {
    await _apiClient.dio.delete(ApiEndpoints.deleteCover);
  }

  Future<void> deleteHighlight(int photoId) async {
    await _apiClient.dio.delete(ApiEndpoints.deleteHighlight(photoId));
  }
}