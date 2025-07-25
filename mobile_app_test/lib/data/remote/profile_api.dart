  // lib/data/remote/profile_api.dart
  import 'package:dio/dio.dart';
  import '../../core/api/api_client.dart';
  import '../../core/constants/api_endpoints.dart';
  import 'package:flutter/foundation.dart';

  class ProfileApi {
    final ApiClient _apiClient;

    ProfileApi(this._apiClient);

    // Fetch current user's profile from the backend API
    Future<Map<String, dynamic>> getProfile() async {
      try {
        final response = await _apiClient.get(ApiEndpoints.updateProfile); // Endpoint: /profiles/me
        if (response.statusCode == 200) {
          // Add detailed logging for debugging
          debugPrint('API Response Data: ${response.data}');
          debugPrint('Body Type from API: ${response.data['bodyType']}');
          debugPrint('Height from API: ${response.data['height']}');
          
          if (response.data['bodyType'] == null || response.data['height'] == null) {
            debugPrint('Warning: Missing appearance data in API response');
          }
          
          return response.data as Map<String, dynamic>;
        } else {
          debugPrint('API Error Response: ${response.statusCode} - ${response.data}');
          throw Exception('Failed to fetch profile: ${response.statusCode}');
        }
      } on DioException catch (e) {
        // Log error details for debugging
        debugPrint('Error fetching profile: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception('Error fetching profile: ${e.message}');
      } catch (e) {
        debugPrint('Unexpected error in getProfile: $e');
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
        debugPrint('Error fetching user info: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception('Error fetching user info: ${e.message}');
      } catch (e) {
        debugPrint('Unexpected error in getUserInfo: $e');
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
        debugPrint('Error fetching profile options: \\${e.response?.statusCode} - \\${e.response?.data}');
        throw Exception('Error fetching profile options: \\${e.message}');
      } catch (e) {
        debugPrint('Unexpected error in getProfileOptions: $e');
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
        debugPrint('Error uploading avatar: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to upload avatar');
      } catch (e) {
        debugPrint('Unexpected error in uploadAvatar: $e');
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
        debugPrint('Error uploading cover: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to upload cover');
      } catch (e) {
        debugPrint('Unexpected error in uploadCover: $e');
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
        debugPrint('Error uploading highlight: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? 'Failed to upload highlight');
      } catch (e) {
        debugPrint('Unexpected error in uploadHighlight: $e');
        throw Exception('Failed to upload highlight: $e');
      }
    }

    Future<void> deleteAvatar() async {
      try {
        final response = await _apiClient.dio.delete(ApiEndpoints.deleteAvatar);
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception('Failed to delete avatar: ${response.statusCode}');
        }
        debugPrint('Delete avatar response: ${response.statusCode}');
      } catch (e) {
        debugPrint('Error in deleteAvatar: $e');
        rethrow;
      }
    }

    Future<void> deleteCover() async {
      try {
        final response = await _apiClient.dio.delete(ApiEndpoints.deleteCover);
        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception('Failed to delete cover: ${response.statusCode}');
        }
        debugPrint('Delete cover response: ${response.statusCode}');
      } catch (e) {
        debugPrint('Error in deleteCover: $e');
        rethrow;
      }
    }

    Future<void> deleteHighlight(int photoId) async {
      await _apiClient.dio.delete(ApiEndpoints.deleteHighlight(photoId));
    }
    
    /// Lấy avatar của user khác theo userId
    /// API endpoint: GET /profiles/photos/{userId}/avatar
    Future<String?> getUserAvatar(String userId) async {
      try {
        final response = await _apiClient.get(ApiEndpoints.getUserAvatar(userId));
        if (response.statusCode == 200 && response.data != null) {
          final photoData = response.data as Map<String, dynamic>;
          return photoData['url'] as String?;
        }
        return null;
      } catch (e) {
        debugPrint('Error getting user avatar for userId $userId: $e');
        return null;
      }
    }
    
    /// Lấy cover photo của user khác theo userId
    /// API endpoint: GET /profiles/photos/{userId}/cover
    Future<String?> getUserCover(String userId) async {
      try {
        final response = await _apiClient.get(ApiEndpoints.getUserCover(userId));
        if (response.statusCode == 200 && response.data != null) {
          final photoData = response.data as Map<String, dynamic>;
          return photoData['url'] as String?;
        }
        return null;
      } catch (e) {
        debugPrint('Error getting user cover for userId $userId: $e');
        return null;
      }
    }
  }

