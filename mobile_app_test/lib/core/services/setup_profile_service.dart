import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import '../../data/remote/setup_profile_api.dart';
import '../../data/repositories/setup_profile_repository.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';

class SetupProfileService {
  final SetupProfileRepository _setupProfileRepository;

  SetupProfileService({SetupProfileRepository? setupProfileRepository})
      : _setupProfileRepository = setupProfileRepository ??
            SetupProfileRepository(SetupProfileApi(
              GetIt.I<ApiClient>(),
              GetIt.I<AuthService>(),
            ));

  Future<Map<String, dynamic>> fetchProfileOptions() async {
    try {
      return await _setupProfileRepository.getProfileOptions();
    } catch (e) {
      debugPrint('Error in fetchProfileOptions service: $e'); // Log lỗi
      rethrow; // Ném lỗi để ViewModel xử lý
    }
  }

  Future<Map<String, dynamic>> uploadPhoto(File file, String endpoint) async {
    try {
      return await _setupProfileRepository.uploadPhoto(file, endpoint);
    } catch (e) {
      debugPrint('Error in uploadPhoto service: $e'); // Log lỗi
      rethrow;
    }
  }

  Future<void> deletePhoto(String endpoint) async {
    try {
      await _setupProfileRepository.deletePhoto(endpoint);
    } catch (e) {
      debugPrint('Error in deletePhoto service: $e');
      rethrow;
    }
  }
}
