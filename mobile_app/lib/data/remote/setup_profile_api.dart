import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/auth_service.dart';

class SetupProfileApi {
  final ApiClient _apiClient;
  final AuthService _authService;

  SetupProfileApi(this._apiClient, this._authService);

  Future<Map<String, dynamic>> getProfileOptions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profileOptions);
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (!data.containsKey('orientations') || data['orientations'] == null) {
          data['orientations'] = [];
        }
        if (!data.containsKey('bodyTypes') || data['bodyTypes'] == null) {
          data['bodyTypes'] = [];
        }
        print('Received body types from API: ${data['bodyTypes']}');
        return data;
      } else {
        throw Exception('Failed to fetch profile options: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProfileOptions: $e');
      throw Exception('Error fetching profile options: $e');
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(File file, String endpoint) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('File size exceeds 10MB limit');
      }

      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: MediaType.parse('image/jpeg'),
        ),
      });

      if (kDebugMode) {
        print('Uploading photo to: $endpoint');
        print('File path: ${file.path}');
        print('File size: $fileSize bytes');
        print('Access token: ${accessToken.substring(0, 10)}...');
      }

      final response = await _apiClient.dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (kDebugMode) {
        print('Upload response status: ${response.statusCode}');
        print('Upload response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('Server returned empty response');
        }

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          if (data['url'] == null) {
            throw Exception('Server response missing photo URL');
          }
          return data;
        } else {
          throw Exception('Invalid response format: Expected Map but got ${response.data.runtimeType}');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        String errorMessage = 'Failed to upload photo';
        if (response.data is Map<String, dynamic>) {
          errorMessage = response.data['message'] ?? errorMessage;
        } else if (response.data is String && response.data.isNotEmpty) {
          errorMessage = response.data;
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('DioException: ${e.message}');
        print('Response data: ${e.response?.data}');
        print('Response status: ${e.response?.statusCode}');
        print('Error type: ${e.type}');
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Authentication failed. Please log in again.');
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Server response timeout. Please try again.');
      }
      throw Exception('Error uploading photo: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading photo: $e');
      }
      throw Exception('Error uploading photo: $e');
    }
  }

  Future<void> deletePhoto(String endpoint) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      final response = await _apiClient.dio.delete(
        endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete photo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        print('Photo not found, skipping deletion');
      } else {
        print('Error in deletePhoto: $e');
        throw Exception('Error deleting photo: $e');
      }
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      // Lọc dữ liệu để chỉ gửi các trường không null
      final filteredData = <String, dynamic>{};
      profileData.forEach((key, value) {
        if (value != null) {
          filteredData[key] = value;
        }
      });

      // Nếu có dữ liệu location, chỉ gửi các trường không null
      if (profileData.containsKey('location')) {
        final location = profileData['location'] as Map<String, dynamic>?;
        if (location != null) {
          final filteredLocation = <String, dynamic>{};
          location.forEach((key, value) {
            if (value != null) {
              filteredLocation[key] = value;
            }
          });
          if (filteredLocation.isNotEmpty) {
            filteredData['location'] = filteredLocation;
          }
        }
      }

      // [API Integration - Debug] Log the data being sent to the backend for verification
      print('Sending update profile request with data: $filteredData');

      // [API Integration] Send PATCH request to update the user profile
      // - Endpoint: /profiles/me
      // - Method: PATCH
      // - Headers: Authorization Bearer <accessToken>, Content-Type: application/json
      // - Body: filteredData (contains fields like interestIds, languageIds, etc.)
      final response = await _apiClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: filteredData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      // [API Integration - Debug] Log the response from the backend for verification
      print('Received update profile response: ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode} - ${response.data['message'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      // [API Integration - Debug] Log detailed error information from DioException
      print('DioException during update profile: ${e.response?.data}');
      print('DioException status code: ${e.response?.statusCode}');
      print('DioException message: ${e.message}');
      throw Exception('Error updating profile: ${e.message} - ${e.response?.data['message'] ?? ''}');
    } catch (e) {
      print('General error during update profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }
}