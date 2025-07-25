import 'package:flutter/foundation.dart';
import '../../../domain/models/match/liked_user_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../core/services/match_service.dart';
import '../../app/di/injection.dart';

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
      // Thay vì mock riêng, lấy data từ discovery service
      final matchService = getIt<MatchService>();
      final discoveryRecommendations = await matchService.getRecommendations();

      // Chuyển đổi từ UserRecommendationModel sang LikedUserModel
      // Coi như những users này đã thích mình
      _likedUsers = _convertDiscoveryToLikedUsers(discoveryRecommendations);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load users who liked you: ${e.toString()}';
      notifyListeners();
    }
  }

  // Convert UserRecommendationModel to LikedUserModel
  List<LikedUserModel> _convertDiscoveryToLikedUsers(
    List<UserRecommendationModel> recommendations,
  ) {
    return recommendations.map((rec) {
      return LikedUserModel(
        id: rec.userId.toString(),
        firstName: rec.firstName,
        lastName: rec.lastName,
        username: rec.username,
        age: rec.age ?? 18, // Fallback age if null
        location: rec.location ?? 'Unknown',
        coverImageUrl:
            rec.photos.isNotEmpty ? rec.photos.first.url : '/placeholder.jpg',
        avatarUrl:
            rec.photos.isNotEmpty
                ? rec.photos.first.url
                : '/placeholder-user.jpg',
        bio: rec.bio ?? 'No bio available',
        photoUrls: rec.photos.map((photo) => photo.url).toList(),
        isVip: false, // Tạm thời set false vì không cần VIP
        profileDetails: {
          'height': rec.height?.toString() ?? 'Unknown',
          'sex': rec.sex ?? 'Unknown',
          'interests': rec.interests.map((i) => i.name).toList(),
          'pets': rec.pets.map((p) => p.name).toList(),
        },
      );
    }).toList();
  }
}
