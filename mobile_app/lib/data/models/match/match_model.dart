// lib/data/models/match/match_model.dart

// Model ghép đôi (Match)
class MatchModel {
  final int id;
  final int user1Id;
  final int user2Id;
  final String status;
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

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as int,
      user1Id: json['user1Id'] as int? ?? json['user1']['id'] as int? ?? 0,
      user2Id: json['user2Id'] as int? ?? json['user2']['id'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      matchedAt: json['matchedAt'] != null 
          ? DateTime.parse(json['matchedAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'status': status,
      'matchedAt': matchedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Check if match is active
  bool get isActive => status.toLowerCase() == 'active';
}

// Enum trạng thái match
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
