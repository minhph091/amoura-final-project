// lib/data/models/matches/recommendation_model.dart

// Model đề xuất ghép đôi (Recommendation)
class RecommendationModel {
  final int id;
  final int userId;
  final double score;
  final String? reason;
  final DateTime? recommendedAt;

  RecommendationModel({
    required this.id,
    required this.userId,
    required this.score,
    this.reason,
    this.recommendedAt,
  });
}