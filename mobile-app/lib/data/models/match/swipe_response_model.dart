class SwipeResponseModel {
  final int swipeId;
  final bool isMatch;
  final int? matchId;
  final int? matchedUserId;
  final String? matchedUsername;
  final String? matchMessage;

  SwipeResponseModel({
    required this.swipeId,
    required this.isMatch,
    this.matchId,
    this.matchedUserId,
    this.matchedUsername,
    this.matchMessage,
  });

  factory SwipeResponseModel.fromJson(Map<String, dynamic> json) {
    return SwipeResponseModel(
      swipeId: json['swipeId'] as int,
      isMatch: json['isMatch'] as bool,
      matchId: json['matchId'] as int?,
      matchedUserId: json['matchedUserId'] as int?,
      matchedUsername: json['matchedUsername'] as String?,
      matchMessage: json['matchMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'swipeId': swipeId,
      'isMatch': isMatch,
      'matchId': matchId,
      'matchedUserId': matchedUserId,
      'matchedUsername': matchedUsername,
      'matchMessage': matchMessage,
    };
  }
} 