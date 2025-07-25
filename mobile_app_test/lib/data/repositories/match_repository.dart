// TODO Implement this library.

import '../remote/match_api.dart';
import '../models/match/user_recommendation_model.dart';
import '../models/match/swipe_request_model.dart';
import '../models/match/swipe_response_model.dart';
import '../models/match/match_model.dart';

class MatchRepository {
  final MatchApi _matchApi;

  MatchRepository(this._matchApi);

  /// Lấy danh sách người dùng được đề xuất
  Future<List<UserRecommendationModel>> getRecommendations() async {
    return await _matchApi.getRecommendations();
  }

  /// Lấy danh sách matches
  Future<List<MatchModel>> getMatches() async {
    return await _matchApi.getMatches();
  }

  /// Swipe người dùng (like/pass)
  Future<SwipeResponseModel> swipeUser(SwipeRequestModel request) async {
    return await _matchApi.swipeUser(request);
  }
}
