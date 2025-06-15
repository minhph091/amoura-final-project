// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';

import '../../data/models/profile/interest_model.dart';
import '../../data/models/profile/profile_model.dart';
import '../../domain/models/match/liked_user_model.dart';
import '../../infrastructure/services/rewind_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  List<ProfileModel> _profiles = [];
  List<InterestModel> _interests = [];
  final RewindService? _rewindService;
  int _currentProfileIndex = 0;
  final List<ProfileModel> _rejectedProfiles = [];

  DiscoveryViewModel([this._rewindService]);

  List<ProfileModel> get profiles => _profiles;
  List<InterestModel> get interests => _interests;
  ProfileModel? get currentProfile =>
      _profiles.isNotEmpty && _currentProfileIndex < _profiles.length
          ? _profiles[_currentProfileIndex]
          : null;
  bool get hasMoreProfiles => _currentProfileIndex < _profiles.length - 1;

  void setProfiles(List<ProfileModel> profiles) {
    _profiles = profiles;
    _currentProfileIndex = 0;
    notifyListeners();
  }

  void setInterests(List<InterestModel> interests) {
    _interests = interests;
    notifyListeners();
  }

  void likeCurrentProfile() {
    if (_currentProfileIndex < _profiles.length) {
      // Handle like logic here
      _moveToNextProfile();
    }
  }

  void dislikeCurrentProfile() {
    if (_currentProfileIndex < _profiles.length) {
      // Store the rejected profile for potential rewind
      final rejected = _profiles[_currentProfileIndex];
      _rejectedProfiles.add(rejected);

      // If rewind service is available, add to rewindable users
      if (_rewindService != null) {
        // Convert ProfileModel to LikedUserModel for rewind service
        final likedUser = _convertToLikedUserModel(rejected);
        _rewindService.addToRewindable(likedUser);
      }

      _moveToNextProfile();
    }
  }

  void superLikeCurrentProfile() {
    if (_currentProfileIndex < _profiles.length) {
      // Handle super like logic here
      _moveToNextProfile();
    }
  }

  void rewindLastProfile() {
    if (_rewindService != null && _rejectedProfiles.isNotEmpty) {
      final lastRejected = _rejectedProfiles.removeLast();

      // Insert the rewound profile before the current profile
      _profiles.insert(_currentProfileIndex, lastRejected);

      // Notify that profiles have changed
      notifyListeners();
    }
  }

  void _moveToNextProfile() {
    if (_currentProfileIndex < _profiles.length) {
      _currentProfileIndex++;
      notifyListeners();
    }
  }

  // Helper method to convert ProfileModel to LikedUserModel
  LikedUserModel _convertToLikedUserModel(ProfileModel profile) {
    // Calculate age from dateOfBirth if available
    int age = 0;
    if (profile.dateOfBirth != null) {
      age = DateTime.now().year - profile.dateOfBirth!.year;
      // Adjust age if birthday hasn't occurred yet this year
      if (DateTime.now().month < profile.dateOfBirth!.month ||
          (DateTime.now().month == profile.dateOfBirth!.month &&
              DateTime.now().day < profile.dateOfBirth!.day)) {
        age--;
      }
    }

    return LikedUserModel(
      id: profile.userId.toString(), // Use userId as the id
      firstName: "User", // Default values since these aren't available in ProfileModel
      lastName: "${profile.userId}",
      username: "user_${profile.userId}", // Create a placeholder username
      age: age,
      location: "Unknown", // Location isn't directly available in ProfileModel
      coverImageUrl: "https://example.com/placeholder.jpg", // Placeholder image
      avatarUrl: "https://example.com/avatar.jpg", // Placeholder avatar
      bio: profile.bio ?? '',
      photoUrls: const [], // No photos available in ProfileModel
      isVip: false, // We don't know from ProfileModel
    );
  }
}