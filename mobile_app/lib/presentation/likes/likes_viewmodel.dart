import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../infrastructure/services/likes_service.dart';
import '../../app/di/injection.dart';

class LikesViewModel extends ChangeNotifier {
  final LikesService _likesService = getIt<LikesService>();
  bool _isLoading = true;
  String? _error;
  List<UserProfile> _likes = [];

  LikesViewModel() {
    try {
      _loadLikes();
    } catch (e) {
      debugPrint('LikesViewModel: Error in constructor: $e');
    }
  }

  bool get isLoading {
    try {
      return _isLoading;
    } catch (e) {
      debugPrint('LikesViewModel: Error getting isLoading: $e');
      return true;
    }
  }
  
  String? get error {
    try {
      return _error;
    } catch (e) {
      debugPrint('LikesViewModel: Error getting error: $e');
      return 'Unknown error';
    }
  }
  
  List<UserProfile> get likes {
    try {
      return _likes;
    } catch (e) {
      debugPrint('LikesViewModel: Error getting likes: $e');
      return [];
    }
  }

  Future<void> _loadLikes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Sử dụng API thật thay vì mock data
      await _likesService.fetchLikedUsers();
      
      // Chuyển đổi từ LikedUserModel sang UserProfile
      _likes = _likesService.likedUsers.map((likedUser) {
        return UserProfile(
          id: likedUser.id,
          firstName: likedUser.firstName,
          lastName: likedUser.lastName,
          age: likedUser.age,
          city: likedUser.location,
          coverPhotoUrl: likedUser.coverImageUrl,
          avatarUrl: likedUser.avatarUrl,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      debugPrint('LikesViewModel: Error loading likes: $e');
      notifyListeners();
    }
  }

  Future<void> refreshLikes() async {
    try {
      await _loadLikes();
    } catch (e) {
      debugPrint('LikesViewModel: Error refreshing likes: $e');
    }
  }
}

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final String city;
  final String coverPhotoUrl;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.city,
    required this.coverPhotoUrl,
    required this.avatarUrl,
  });

  String get fullName {
    try {
      return '$firstName $lastName';
    } catch (e) {
      debugPrint('UserProfile: Error getting full name: $e');
      return 'Unknown User';
    }
  }
}
