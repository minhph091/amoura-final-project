// TODO Implement this library.

import '../../../core/services/match_service.dart';
import '../../../data/models/match/match_model.dart';

class GetMatchesUseCase {
  final MatchService _matchService;

  GetMatchesUseCase(this._matchService);

  Future<List<MatchModel>> execute() async {
    return await _matchService.getMatches();
  }
}