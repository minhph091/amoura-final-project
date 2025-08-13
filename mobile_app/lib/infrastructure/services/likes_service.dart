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
      debugPrint('LikesService: ==> Starting fetchLikedUsers...');
      _isLoading = true;
      _error = null;
      // Clear old data before fetching new data
      _likedUsers = [];
      notifyListeners();

      debugPrint('LikesService: Fetching users who liked current user...');
      
      // Sử dụng API thật thay vì mock data
      final matchService = getIt<MatchService>();
      debugPrint('LikesService: Got MatchService instance, calling getReceivedLikes...');
      
      final receivedLikes = await matchService.getReceivedLikes();
      debugPrint('LikesService: Received ${receivedLikes.length} likes from API');

      // Chuyển đổi từ ReceivedLikeModel sang LikedUserModel
      _likedUsers = _convertReceivedLikesToLikedUsers(receivedLikes);

      debugPrint('LikesService: Successfully loaded ${_likedUsers.length} users who liked current user');
      debugPrint('LikesService: Users: ${_likedUsers.map((u) => '${u.firstName} ${u.lastName}').join(', ')}');
      debugPrint('LikesService: Avatar URLs: ${_likedUsers.map((u) => u.avatarUrl).join(', ')}');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load users who liked you: ${e.toString()}';
      debugPrint('LikesService: ERROR fetching liked users: $e');
      debugPrint('LikesService: Error type: ${e.runtimeType}');
      debugPrint('LikesService: Error details: ${e.toString()}');
      
      notifyListeners();
    }
  }

  // Convert ReceivedLikeModel to LikedUserModel
  List<LikedUserModel> _convertReceivedLikesToLikedUsers(
    List<ReceivedLikeModel> receivedLikes,
  ) {
    try {
      return receivedLikes.map((receivedLike) {
        // Process avatar URL to ensure it's a valid URL
        String? avatarUrl = _validateAvatarUrl(receivedLike.primaryPhotoUrl);
        
        // Use placeholder if no avatar URL
        if (avatarUrl == null) {
          avatarUrl = 'https://api.amoura.space/api/files/users/1/avatar.jpg'; // Use production server URL
          debugPrint('LikesService: Using fallback avatar for user ${receivedLike.firstName}');
        }
        
        debugPrint('LikesService: Processing user ${receivedLike.firstName} with avatar: $avatarUrl');
        
        return LikedUserModel(
          id: receivedLike.userId.toString(),
          firstName: receivedLike.firstName,
          lastName: receivedLike.lastName,
          username: receivedLike.username,
          age: receivedLike.age ?? 18, // Fallback age if null
          location: receivedLike.location ?? 'Unknown',
          coverImageUrl: avatarUrl,
          avatarUrl: avatarUrl,
          bio: receivedLike.bio ?? 'No bio available',
          photoUrls: receivedLike.photos.map((photo) {
            return _validateAvatarUrl(photo.url) ?? avatarUrl!;
          }).toList(),
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

  // Clear all data (useful for app restart)
  void clearData() {
    _likedUsers = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
    debugPrint('LikesService: Data cleared');
  }

  // Create mock data for testing UI (REMOVED - only use real API data)
  List<LikedUserModel> _createMockLikedUsers() {
    // Mock data removed - only use real API data
    return [];
  }

  // Helper method to validate and fix avatar URLs
  String? _validateAvatarUrl(String? url) {
    if (url == null || url.isEmpty) {
      return null;
    }

    // If it's already a valid HTTP URL, return it
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // If it's a relative path starting with /, make it absolute with production server
    if (url.startsWith('/')) {
      return 'https://api.amoura.space/api$url';
    }

    // If it's a relative path not starting with /, add / and use production server
    return 'https://api.amoura.space/api/files/$url';
  }
}
