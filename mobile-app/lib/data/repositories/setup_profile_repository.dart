// lib/data/repositories/setup_profile_repository.dart
import 'dart:io';
import '../remote/setup_profile_api.dart';

class SetupProfileRepository {
  final SetupProfileApi _setupProfileApi;

  SetupProfileRepository(this._setupProfileApi);

  Future<Map<String, dynamic>> getProfileOptions() async {
    return await _setupProfileApi.getProfileOptions();
  }

  Future<Map<String, dynamic>> uploadPhoto(File file, String endpoint) async {
    return await _setupProfileApi.uploadPhoto(file, endpoint);
  }
}