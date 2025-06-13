// lib/core/services/profile_service.dart
import 'package:get_it/get_it.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/remote/profile_api.dart';
import '../../core/api/api_client.dart';

class ProfileService {
  final ProfileRepository _profileRepository;

  ProfileService({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ??
            ProfileRepository(ProfileApi(GetIt.I<ApiClient>()));

  // Fetch profile data and merge it with user data
  // Comment: This method combines profile data (/profiles/me) with user data (/user) to provide a complete dataset
  Future<Map<String, dynamic>> getProfile() async {
    try {
      // Fetch profile data from /profiles/me
      final profileData = await _profileRepository.getProfile();
      
      // Fetch user data from /user
      final userData = await _profileRepository.getUserInfo();
      
      // Merge user data into profile data
      // Comment: Extract and merge critical fields (firstName, lastName, username) into the profile map
      profileData['firstName'] = userData['firstName'];
      profileData['lastName'] = userData['lastName'];
      profileData['username'] = userData['username'];
      
      return profileData;
    } catch (e) {
      print('Error in ProfileService.getProfile: $e');
      rethrow; // Propagate error to the upper layers
    }
  }
}