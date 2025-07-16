// lib/core/services/profile_service.dart
import 'package:flutter/foundation.dart';
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

      // Map avatarUrl and coverUrl from photos array
      // Comment: Extract avatar and cover photo URLs from the 'photos' array for UI display
      if (profileData['photos'] != null && profileData['photos'] is List) {
        final photos = profileData['photos'] as List;
        final avatar = photos.firstWhere(
          (p) => p['type'] == 'avatar',
          orElse: () => null,
        );
        final cover = photos.firstWhere(
          (p) => p['type'] == 'profile_cover',
          orElse: () => null,
        );
        profileData['avatarUrl'] = avatar != null ? fixLocalhostUrl(avatar['url']) : null;
        profileData['coverUrl'] = cover != null ? fixLocalhostUrl(cover['url']) : null;

        // Thêm đoạn này để map galleryPhotos
        final highlights = photos
            .where((p) => p['type'] == 'highlight')
            .map((p) => fixLocalhostUrl(p['url']))
            .toList();
        profileData['galleryPhotos'] = highlights;
      }
      
      return profileData;
    } catch (e) {
      debugPrint('Error in ProfileService.getProfile: $e');
      rethrow; // Propagate error to the upper layers
    }
  }

  // Lấy options cho profile từ repository
  Future<Map<String, dynamic>> getProfileOptions() async {
    try {
      return await _profileRepository.getProfileOptions();
    } catch (e) {
      debugPrint('Error in ProfileService.getProfileOptions: $e');
      rethrow;
    }
  }
}

// Helper: Fix localhost/127.0.0.1 url for Android emulator
// Comment: Android emulator không truy cập được localhost/127.0.0.1 của máy host, phải dùng 10.0.2.2
String fixLocalhostUrl(String? url) {
  if (url == null) return '';
  return url
      .replaceAll('http://localhost:', 'http://10.0.2.2:')
      .replaceAll('http://127.0.0.1:', 'http://10.0.2.2:');
}
