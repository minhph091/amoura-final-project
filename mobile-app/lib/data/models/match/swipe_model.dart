// lib/data/models/matches/swipe_model.dart

// Model swipe (Vuốt thích/không thích)
class SwipeModel {
  final int id;
  final int initiator;
  final int targetUser;
  final bool isLike;
  final DateTime createdAt;

  SwipeModel({
    required this.id,
    required this.initiator,
    required this.targetUser,
    required this.isLike,
    required this.createdAt,
  });
}