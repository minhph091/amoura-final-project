import 'package:flutter/foundation.dart';
import '../../../domain/models/match/liked_user_model.dart';
import '../../../data/models/match/received_like_model.dart';
import '../../core/services/match_service.dart';
import '../../app/di/injection.dart';

class LikesService with ChangeNotifier {
  bool _isLoading = false;
  List<LikedUserModel> _likedUsers = [];
  String? _error;

  LikesService() {
    try {
      // Constructor logic if needed
    } catch (e) {
      debugPrint('LikesService: Error in constructor: $e');
    }
  }

  bool get isLoading {
    try {
      return _isLoading;
    } catch (e) {
      debugPrint('LikesService: Error getting isLoading: $e');
      return true;
    }
  }
  
  List<LikedUserModel> get likedUsers {
    try {
      return _likedUsers;
    } catch (e) {
      debugPrint('LikesService: Error getting likedUsers: $e');
      return [];
    }
  }
  
  String? get error {
    try {
      return _error;
    } catch (e) {
      debugPrint('LikesService: Error getting error: $e');
      return 'Unknown error';
    }
  }

  // Fetch users who liked the current user
  Future<void> fetchLikedUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('LikesService: Fetching users who liked current user...');
      
      // Sử dụng API thật thay vì mock data
      final matchService = getIt<MatchService>();
      final receivedLikes = await matchService.getReceivedLikes();

      // Chuyển đổi từ ReceivedLikeModel sang LikedUserModel
      _likedUsers = _convertReceivedLikesToLikedUsers(receivedLikes);

      debugPrint('LikesService: Successfully loaded ${_likedUsers.length} users who liked current user');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load users who liked you: ${e.toString()}';
      debugPrint('LikesService: Error fetching liked users: $e');
      notifyListeners();
    }
  }

  // Convert ReceivedLikeModel to LikedUserModel
  List<LikedUserModel> _convertReceivedLikesToLikedUsers(
    List<ReceivedLikeModel> receivedLikes,
  ) {
    try {
      return receivedLikes.map((receivedLike) {
        return LikedUserModel(
          id: receivedLike.userId.toString(),
          firstName: receivedLike.firstName,
          lastName: receivedLike.lastName,
          username: receivedLike.username,
          age: receivedLike.age ?? 18, // Fallback age if null
          location: receivedLike.location ?? 'Unknown',
          coverImageUrl: receivedLike.primaryPhotoUrl ?? '/placeholder.jpg',
          avatarUrl: receivedLike.primaryPhotoUrl ?? '/placeholder-user.jpg',
          bio: receivedLike.bio ?? 'No bio available',
          photoUrls: receivedLike.photos.map((photo) => photo.url).toList(),
          isVip: false, // Tạm thời set false vì không cần VIP
          profileDetails: {
            'height': receivedLike.height?.toString() ?? 'Unknown',
            'sex': receivedLike.sex ?? 'Unknown',
            'interests': receivedLike.interests.map((i) => i.name).toList(),
            'pets': receivedLike.pets.map((p) => p.name).toList(),
            'likedAt': receivedLike.likedAt.toIso8601String(),
          },
        );
      }).toList();
    } catch (e) {
      debugPrint('LikesService: Error converting received likes to liked users: $e');
      return [];
    }
  }
}
