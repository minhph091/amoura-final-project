import 'package:flutter/foundation.dart';
import '../../../domain/models/match/liked_user_model.dart';

class LikesService with ChangeNotifier {
  bool _isLoading = false;
  List<LikedUserModel> _likedUsers = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<LikedUserModel> get likedUsers => _likedUsers;
  String? get error => _error;

  // Fetch users who liked the current user
  Future<void> fetchLikedUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would normally be an API call
      await Future.delayed(const Duration(milliseconds: 1500));

      // Mock data for demonstration purposes
      _likedUsers = _generateMockLikedUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load users who liked you: ${e.toString()}';
      notifyListeners();
    }
  }

  // Mock data generation
  List<LikedUserModel> _generateMockLikedUsers() {
    return [
      LikedUserModel(
        id: '1',
        firstName: 'Emma',
        lastName: 'Watson',
        username: 'emmaw',
        age: 32,
        location: 'London',
        coverImageUrl: 'https://example.com/cover1.jpg',
        avatarUrl: 'https://example.com/avatar1.jpg',
        bio: 'Actress and activist. Love books, travel, and meaningful conversations.',
        photoUrls: ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
        isVip: true,
        profileDetails: {
          'height': '165 cm',
          'occupation': 'Actress',
          'education': 'Brown University',
          'interests': ['Reading', 'Yoga', 'Environmentalism']
        },
      ),
      LikedUserModel(
        id: '2',
        firstName: 'Chris',
        lastName: 'Evans',
        username: 'captainamerica',
        age: 40,
        location: 'Los Angeles',
        coverImageUrl: 'https://example.com/cover2.jpg',
        avatarUrl: 'https://example.com/avatar2.jpg',
        bio: 'Actor who loves dogs and sports. Looking for someone to share adventures with.',
        photoUrls: ['https://example.com/photo3.jpg', 'https://example.com/photo4.jpg'],
        profileDetails: {
          'height': '183 cm',
          'occupation': 'Actor',
          'interests': ['Dogs', 'Sports', 'Movies']
        },
      ),
      LikedUserModel(
        id: '3',
        firstName: 'Sofia',
        lastName: 'Martinez',
        username: 'sofiam',
        age: 28,
        location: 'Barcelona',
        coverImageUrl: 'https://example.com/cover3.jpg',
        avatarUrl: 'https://example.com/avatar3.jpg',
        bio: 'Travel photographer and foodie. I speak 3 languages and love discovering new cultures.',
        photoUrls: ['https://example.com/photo5.jpg', 'https://example.com/photo6.jpg'],
        profileDetails: {
          'height': '170 cm',
          'occupation': 'Photographer',
          'languages': ['English', 'Spanish', 'French'],
          'interests': ['Photography', 'Travel', 'Cooking']
        },
      ),
      LikedUserModel(
        id: '4',
        firstName: 'Keanu',
        lastName: 'Reeves',
        username: 'neo',
        age: 57,
        location: 'New York',
        coverImageUrl: 'https://example.com/cover4.jpg',
        avatarUrl: 'https://example.com/avatar4.jpg',
        bio: 'Actor, musician, and motorcycle enthusiast. Kind heart and old soul.',
        photoUrls: ['https://example.com/photo7.jpg', 'https://example.com/photo8.jpg'],
        isVip: true,
        profileDetails: {
          'height': '186 cm',
          'occupation': 'Actor',
          'interests': ['Motorcycles', 'Music', 'Philosophy']
        },
      ),
    ];
  }
}
