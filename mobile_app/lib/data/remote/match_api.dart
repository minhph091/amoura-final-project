import 'package:flutter/foundation.dart';
import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/match/user_recommendation_model.dart';
import '../models/match/swipe_request_model.dart';
import '../models/match/swipe_response_model.dart';
import '../models/match/match_model.dart';
import '../models/match/received_like_model.dart';

class MatchApi {
  final ApiClient _apiClient;
  
  MatchApi(this._apiClient) {
    try {
      // Constructor logic if needed
    } catch (e) {
      debugPrint('MatchApi: Error in constructor: $e');
    }
  }

  /// Lấy danh sách người dùng được đề xuất
  Future<List<UserRecommendationModel>> getRecommendations() async {
    try {
      final response = await _apiClient.get('/matching/recommendations');
      final data = response.data as List;
      return data.map((e) => UserRecommendationModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('MatchApi: Error getting recommendations: $e');
      rethrow;
    }
  }

  /// Lấy danh sách matches
  Future<List<MatchModel>> getMatches() async {
    try {
      final response = await _apiClient.get('/matching/matches');
      final data = response.data as List;
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('MatchApi: Error getting matches: $e');
      rethrow;
    }
  }

  /// Swipe người dùng (like/pass)
  Future<SwipeResponseModel> swipeUser(SwipeRequestModel request) async {
    try {
      final response = await _apiClient.post('/matching/swipe', data: request.toJson());
      return SwipeResponseModel.fromJson(response.data);
    } catch (e) {
      debugPrint('MatchApi: Error swiping user: $e');
      rethrow;
    }
  }

  /// Lấy danh sách những người đã thích mình
  Future<List<ReceivedLikeModel>> getReceivedLikes() async {
    try {
      final response = await _apiClient.get('/matching/received');
      final data = response.data as List;
      return data.map((e) => ReceivedLikeModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('MatchApi: Error getting received likes: $e');
      rethrow;
    }
  }
}
