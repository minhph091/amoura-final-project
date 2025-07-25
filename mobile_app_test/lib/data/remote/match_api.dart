import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../models/match/user_recommendation_model.dart';
import '../models/match/swipe_request_model.dart';
import '../models/match/swipe_response_model.dart';
import '../models/match/match_model.dart';

class MatchApi {
  final ApiClient _apiClient;

  MatchApi(this._apiClient);

  /// Lấy danh sách người dùng được đề xuất
  Future<List<UserRecommendationModel>> getRecommendations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getRecommendations);
      
      if (response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => UserRecommendationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get recommendations: $e');
    }
  }

  /// Lấy danh sách matches
  Future<List<MatchModel>> getMatches() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.getMatches);
      
      if (response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Failed to get matches: $e');
    }
  }

  /// Swipe người dùng (like/pass)
  Future<SwipeResponseModel> swipeUser(SwipeRequestModel request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.swipeUser,
        data: request.toJson(),
      );
      
      if (response.data != null) {
        return SwipeResponseModel.fromJson(response.data as Map<String, dynamic>);
      }
      
      throw Exception('Invalid response from swipe API');
    } catch (e) {
      throw Exception('Failed to swipe user: $e');
    }
  }
}
