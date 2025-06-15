import 'package:flutter/material.dart';
import '../../../../domain/models/match/liked_user_model.dart';

class ProfileDetailsViewModel with ChangeNotifier {
  final String userId;
  LikedUserModel? _user;
  bool _isLoading = true;
  String? _error;
  bool _isBlocked = false;

  ProfileDetailsViewModel(this.userId, {LikedUserModel? initialData}) {
    _user = initialData;
    if (_user == null) {
      loadProfile();
    } else {
      _isLoading = false;
    }
  }

  LikedUserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isBlocked => _isBlocked;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would normally be an API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data for demonstration
      _user = _generateMockUserProfile(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load profile: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> blockUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      await Future.delayed(const Duration(milliseconds: 800));
      _isBlocked = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to block user: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> unblockUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // This would be an API call in a real app
      await Future.delayed(const Duration(milliseconds: 800));
      _isBlocked = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to unblock user: ${e.toString()}';
      notifyListeners();
    }
  }

  // Helper method to generate mock user data
  LikedUserModel _generateMockUserProfile(String id) {
    final int idNum = int.tryParse(id) ?? 0;

    return LikedUserModel(
      id: id,
      firstName: ['Emma', 'Chris', 'Sofia', 'Keanu', 'Alex', 'Mia'][idNum % 6],
      lastName: ['Watson', 'Evans', 'Martinez', 'Reeves', 'Johnson', 'Chen'][idNum % 6],
      username: ['emmaw', 'captainamerica', 'sofiam', 'neo', 'alexj', 'miac'][idNum % 6],
      age: 25 + (idNum % 15),
      location: ['New York', 'Los Angeles', 'Barcelona', 'Tokyo', 'London', 'Sydney'][idNum % 6],
      coverImageUrl: 'https://picsum.photos/seed/${idNum+10}/800/600',
      avatarUrl: 'https://picsum.photos/seed/$idNum/200/200',
      bio: 'This is a mock bio for user $id. ' +
          'I love traveling, hiking, and trying new foods. ' +
          'Looking for someone to share adventures with.',
      photoUrls: List.generate(
        4,
        (i) => 'https://picsum.photos/seed/${idNum + i * 10}/400/600'
      ),
      isVip: idNum % 3 == 0,
      profileDetails: {
        'height': '${165 + (idNum % 25)} cm',
        'occupation': ['Engineer', 'Doctor', 'Designer', 'Teacher', 'Entrepreneur'][idNum % 5],
        'education': ['University of Life', 'Stanford', 'MIT', 'Harvard', 'Oxford'][idNum % 5],
        'interests': [
          'Photography',
          'Traveling',
          'Cooking',
          'Hiking',
          'Reading',
          'Art',
          'Movies',
          'Music'
        ].sublist(0, 3 + (idNum % 5)),
        'languages': [
          'English',
          'Spanish',
          'French',
          'German',
          'Italian',
          'Japanese'
        ].sublist(0, 1 + (idNum % 3)),
      },
    );
  }
}
