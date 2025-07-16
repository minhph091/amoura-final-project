// lib/core/services/profile_options_service.dart
// Service to fetch profile options from API or fallback to local constants.

import 'package:dio/dio.dart';
import '../constants/profile/body_type_constants.dart';
import '../constants/profile/education_constants.dart';
import '../constants/profile/interest_constants.dart';
import '../constants/profile/job_constants.dart';
import '../constants/profile/language_constants.dart';
import '../constants/profile/orientation_constants.dart';
import '../constants/profile/pet_constants.dart';
import '../constants/profile/sex_constants.dart';
import '../constants/profile/smoke_drink_constants.dart';

class ProfileOptionsService {
  final Dio _dio;

  ProfileOptionsService(this._dio);

  // Fetch options from API or return local constants
  Future<List<Map<String, dynamic>>> getOptions(String type) async {
    try {
      final response = await _dio.get('/profile-options/$type');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
    } catch (e) {
      // Fallback to local constants on error
    }
    switch (type) {
      case 'body_type':
        return bodyTypeOptions;
      case 'sex':
        return sexOptions;
      case 'orientation':
        return orientationOptions;
      case 'job':
        return jobOptions;
      case 'education':
        return educationOptions;
      case 'drink':
        return drinkOptions;
      case 'smoke':
        return smokeOptions;
      case 'pet':
        return petOptions;
      case 'interest':
        return interestOptions;
      case 'language':
        return languageOptions;
      default:
        return [];
    }
  }
}
