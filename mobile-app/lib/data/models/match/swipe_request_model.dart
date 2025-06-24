class SwipeRequestModel {
  final int targetUserId;
  final bool isLike;

  SwipeRequestModel({
    required this.targetUserId,
    required this.isLike,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetUserId': targetUserId,
      'isLike': isLike,
    };
  }
} 