class Chat {
  final String id;
  final List<String> participantIds;
  final String? groupName;
  final String? groupAvatar;
  final bool isGroup;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final DateTime? lastSeenAt;
  final bool muted;
  final bool pinned;

  Chat({
    required this.id,
    required this.participantIds,
    this.groupName,
    this.groupAvatar,
    this.isGroup = false,
    this.lastMessage,
    this.lastMessageTime,
    this.lastSeenAt,
    this.muted = false,
    this.pinned = false,
  });

  Chat copyWith({
    String? id,
    List<String>? participantIds,
    String? groupName,
    String? groupAvatar,
    bool? isGroup,
    String? lastMessage,
    DateTime? lastMessageTime,
    DateTime? lastSeenAt,
    bool? muted,
    bool? pinned,
  }) {
    return Chat(
      id: id ?? this.id,
      participantIds: participantIds ?? this.participantIds,
      groupName: groupName ?? this.groupName,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      isGroup: isGroup ?? this.isGroup,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      muted: muted ?? this.muted,
      pinned: pinned ?? this.pinned,
    );
  }
}
