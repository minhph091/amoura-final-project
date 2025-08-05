// TODO Implement this library.

import 'package:flutter/foundation.dart';
import '../../data/remote/match_api.dart';
import '../models/match/user_recommendation_model.dart';
import '../models/match/swipe_request_model.dart';
import '../models/match/swipe_response_model.dart';
import '../models/match/match_model.dart';
import '../models/match/received_like_model.dart';

class MatchRepository {
  final MatchApi _matchApi;

  MatchRepository(this._matchApi) {
    try {
      // Constructor logic if needed
    } catch (e) {
      debugPrint('MatchRepository: Error in constructor: $e');
    }
  }

  /// Lấy danh sách người dùng được đề xuất
  Future<List<UserRecommendationModel>> getRecommendations() async {
    try {
      return await _matchApi.getRecommendations();
    } catch (e) {
      debugPrint('MatchRepository: Error getting recommendations: $e');
      rethrow;
    }
  }

  /// Lấy danh sách matches
  Future<List<MatchModel>> getMatches() async {
    try {
      return await _matchApi.getMatches();
    } catch (e) {
      debugPrint('MatchRepository: Error getting matches: $e');
      rethrow;
    }
  }

  /// Swipe người dùng (like/pass)
  Future<SwipeResponseModel> swipeUser(SwipeRequestModel request) async {
    try {
      return await _matchApi.swipeUser(request);
    } catch (e) {
      debugPrint('MatchRepository: Error swiping user: $e');
      rethrow;
    }
  }

  /// Lấy danh sách những người đã thích mình
  Future<List<ReceivedLikeModel>> getReceivedLikes() async {
    try {
      return await _matchApi.getReceivedLikes();
    } catch (e) {
      debugPrint('MatchRepository: Error getting received likes: $e');
      rethrow;
    }
  }
}
