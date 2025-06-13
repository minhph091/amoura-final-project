// lib/data/repositories/profile_repository.dart
import '../remote/profile_api.dart';

class ProfileRepository {
  final ProfileApi _profileApi;

  ProfileRepository(this._profileApi);

  // Retrieve profile data by delegating to ProfileApi
  Future<Map<String, dynamic>> getProfile() async {
    return await _profileApi.getProfile();
  }

  // Retrieve user info by delegating to ProfileApi
  // Comment: This method acts as a bridge between the service layer and the API layer for user data
  Future<Map<String, dynamic>> getUserInfo() async {
    return await _profileApi.getUserInfo();
  }

  // Lấy options cho profile từ API
  Future<Map<String, dynamic>> getProfileOptions() async {
    return await _profileApi.getProfileOptions();
  }
}