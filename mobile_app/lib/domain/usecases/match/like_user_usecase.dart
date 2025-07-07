// TODO Implement this library.

import '../../../core/services/match_service.dart';
import '../../../data/models/match/swipe_response_model.dart';

class LikeUserUseCase {
  final MatchService _matchService;

  LikeUserUseCase(this._matchService);

  Future<SwipeResponseModel> execute(int targetUserId) async {
    return await _matchService.likeUser(targetUserId);
  }
}