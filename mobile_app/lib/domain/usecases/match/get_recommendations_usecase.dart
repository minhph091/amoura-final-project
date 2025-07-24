// TODO Implement this library.

import '../../../core/services/match_service.dart';
import '../../../data/models/match/user_recommendation_model.dart';

class GetRecommendationsUseCase {
  final MatchService _matchService;

  GetRecommendationsUseCase(this._matchService);

  Future<List<UserRecommendationModel>> execute() async {
    return await _matchService.getRecommendations();
  }
}
