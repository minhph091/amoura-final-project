// lib/data/models/matches/match_model.dart

// Model ghép đôi (Match)
class MatchModel {
  final int id;
  final int user1Id;
  final int user2Id;
  final MatchStatus status;
  final DateTime matchedAt;
  final DateTime? updatedAt;

  MatchModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    required this.matchedAt,
    this.updatedAt,
  });
}

// Enum trạng thái matches
enum MatchStatus { active, unmatched }

MatchStatus matchStatusFromString(String value) {
  switch (value) {
    case 'active':
      return MatchStatus.active;
    case 'unmatched':
      return MatchStatus.unmatched;
    default:
      return MatchStatus.unmatched;
  }
}