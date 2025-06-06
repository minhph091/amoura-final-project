// lib/data/remote/setup_profile_api.dart
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

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final accessToken = await _authService.getAccessToken();
      if (accessToken == null) {
        throw Exception('Authentication required. Please log in again.');
      }

      final response = await _apiClient.dio.patch(
        ApiEndpoints.updateProfile,
        data: {
          'orientationId': profileData['orientationId'],
          'orientation': profileData['orientation'],
          'location': {
            'latitude': profileData['latitude'],
            'longitude': profileData['longitude'],
            'country': profileData['country'],
            'state': profileData['state'],
            'city': profileData['city'],
          },
          'locationPreference': profileData['locationPreference'],
          'bodyTypeId': profileData['bodyTypeId'],
          'bodyType': profileData['bodyType'],
          'height': profileData['height'],
          'jobIndustryId': profileData['jobIndustryId'],
          'jobIndustry': profileData['jobIndustry'],
          'educationLevelId': profileData['educationLevelId'],
          'educationLevel': profileData['educationLevel'],
          'dropOut': profileData['dropOut'],
          'drinkStatusId': profileData['drinkStatusId'],
          'drinkStatus': profileData['drinkStatus'],
          'smokeStatusId': profileData['smokeStatusId'],
          'smokeStatus': profileData['smokeStatus'],
          'selectedPets': profileData['selectedPets'],
          'selectedInterestIds': profileData['selectedInterestIds'],
          'selectedLanguageIds': profileData['selectedLanguageIds'],
          'interestedInNewLanguage': profileData['interestedInNewLanguage'],
          'bio': profileData['bio'],
          'galleryPhotos': profileData['galleryPhotos'],
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error updating profile: ${e.message}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}