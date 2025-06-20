import 'package:get_it/get_it.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/remote/match_api.dart';
import '../../core/api/api_client.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/match/swipe_request_model.dart';
import '../../data/models/match/swipe_response_model.dart';
import '../../data/models/match/match_model.dart';

class MatchService {
  final MatchRepository _matchRepository;

  MatchService({MatchRepository? matchRepository})
      : _matchRepository = matchRepository ??
            MatchRepository(MatchApi(GetIt.I<ApiClient>()));

  /// Lấy danh sách người dùng được đề xuất
  Future<List<UserRecommendationModel>> getRecommendations() async {
    try {
      return await _matchRepository.getRecommendations();
    } catch (e) {
      print('Error in MatchService.getRecommendations: $e');
      rethrow;
    }
  }

  /// Lấy danh sách matches
  Future<List<MatchModel>> getMatches() async {
    try {
      return await _matchRepository.getMatches();
    } catch (e) {
      print('Error in MatchService.getMatches: $e');
      rethrow;
    }
  }

  /// Swipe người dùng (like/pass)
  Future<SwipeResponseModel> swipeUser(SwipeRequestModel request) async {
    try {
      return await _matchRepository.swipeUser(request);
    } catch (e) {
      print('Error in MatchService.swipeUser: $e');
      rethrow;
    }
  }

  /// Like người dùng
  Future<SwipeResponseModel> likeUser(int targetUserId) async {
    try {
      final request = SwipeRequestModel(
        targetUserId: targetUserId,
        isLike: true,
      );
      return await _matchRepository.swipeUser(request);
    } catch (e) {
      print('Error in MatchService.likeUser: $e');
      rethrow;
    }
  }

  /// Dislike người dùng
  Future<SwipeResponseModel> dislikeUser(int targetUserId) async {
    try {
      final request = SwipeRequestModel(
        targetUserId: targetUserId,
        isLike: false,
      );
      return await _matchRepository.swipeUser(request);
    } catch (e) {
      print('Error in MatchService.dislikeUser: $e');
      rethrow;
    }
  }
}
