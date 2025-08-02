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
        location: 'London, UK',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Actress and activist. Love books, travel, and meaningful conversations.',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        isVip: true,
        profileDetails: {
          'height': '165 cm',
          'occupation': 'Actress',
          'education': 'Brown University',
          'interests': ['Reading', 'Yoga', 'Environmentalism'],
        },
      ),
      LikedUserModel(
        id: '2',
        firstName: 'Chris',
        lastName: 'Evans',
        username: 'captainamerica',
        age: 40,
        location: 'Los Angeles, CA',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Actor who loves dogs and sports. Looking for someone to share adventures with.',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        profileDetails: {
          'height': '183 cm',
          'occupation': 'Actor',
          'interests': ['Dogs', 'Sports', 'Movies'],
        },
      ),
      LikedUserModel(
        id: '3',
        firstName: 'Sophia',
        lastName: 'Rodriguez',
        username: 'sophiar',
        age: 28,
        location: 'Barcelona, Spain',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Travel photographer capturing moments around the world. Always seeking new adventures.',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        isVip: false,
        profileDetails: {
          'height': '168 cm',
          'occupation': 'Photographer',
          'education': 'Art Institute',
          'interests': ['Photography', 'Travel', 'Art'],
        },
      ),
      LikedUserModel(
        id: '4',
        firstName: 'David',
        lastName: 'Kim',
        username: 'davidk',
        age: 35,
        location: 'Seoul, South Korea',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Software engineer by day, chef by night. Love creating delicious experiences.',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        isVip: true,
        profileDetails: {
          'height': '175 cm',
          'occupation': 'Software Engineer',
          'education': 'KAIST',
          'interests': ['Coding', 'Cooking', 'Gaming'],
        },
      ),
      LikedUserModel(
        id: '5',
        firstName: 'Luna',
        lastName: 'Silva',
        username: 'lunas',
        age: 26,
        location: 'Rio de Janeiro, Brazil',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Dance instructor with a passion for music and movement. Life is about rhythm!',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        isVip: false,
        profileDetails: {
          'height': '162 cm',
          'occupation': 'Dance Instructor',
          'interests': ['Dancing', 'Music', 'Fitness'],
        },
      ),
      LikedUserModel(
        id: '6',
        firstName: 'Alexander',
        lastName: 'Petrov',
        username: 'alexp',
        age: 31,
        location: 'Moscow, Russia',
        coverImageUrl: '/placeholder.jpg',
        avatarUrl: '/placeholder-user.jpg',
        bio:
            'Architect designing sustainable buildings. Passionate about creating a better future.',
        photoUrls: ['/placeholder.jpg', '/placeholder-user.jpg'],
        isVip: true,
        profileDetails: {
          'height': '180 cm',
          'occupation': 'Architect',
          'education': 'Moscow State University',
          'interests': ['Architecture', 'Sustainability', 'Art'],
        },
      ),
    ];
  }
}
