import 'message.dart';

class Chat {
  final String id;
  final String? user1Id;
  final String? user1Name;
  final String? user1Avatar;
  final String? user2Id;
  final String? user2Name;
  final String? user2Avatar;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? unreadCount;
  final Message? lastMessage;
  
  // Computed properties for easier access
  String? get participantName => user1Name ?? user2Name;
  String? get participantAvatar => user1Avatar ?? user2Avatar;
  DateTime? get lastMessageTime => lastMessage?.timestamp ?? updatedAt;
  List<String> get participantIds => [
    if (user1Id != null) user1Id!,
    if (user2Id != null) user2Id!,
  ];
  bool get isGroup => false; // Chat rooms are always 1-on-1
  String? get groupName => null;
  String? get groupAvatar => null;
  bool get muted => false;
  bool get pinned => false;
  DateTime? get lastSeenAt => updatedAt;

  Chat({
    required this.id,
    this.user1Id,
    this.user1Name,
    this.user1Avatar,
    this.user2Id,
    this.user2Name,
    this.user2Avatar,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.unreadCount,
    this.lastMessage,
  });

  Chat copyWith({
    String? id,
    String? user1Id,
    String? user1Name,
    String? user1Avatar,
    String? user2Id,
    String? user2Name,
    String? user2Avatar,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? unreadCount,
    Message? lastMessage,
  }) {
    return Chat(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user1Name: user1Name ?? this.user1Name,
      user1Avatar: user1Avatar ?? this.user1Avatar,
      user2Id: user2Id ?? this.user2Id,
      user2Name: user2Name ?? this.user2Name,
      user2Avatar: user2Avatar ?? this.user2Avatar,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id']?.toString() ?? '',
      user1Id: json['user1Id']?.toString(),
      user1Name: json['user1Name'],
      user1Avatar: json['user1Avatar'],
      user2Id: json['user2Id']?.toString(),
      user2Name: json['user2Name'],
      user2Avatar: json['user2Avatar'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      unreadCount: json['unreadCount'],
      lastMessage: json['lastMessage'] != null 
          ? Message.fromJson(json['lastMessage']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user1Name': user1Name,
      'user1Avatar': user1Avatar,
      'user2Id': user2Id,
      'user2Name': user2Name,
      'user2Avatar': user2Avatar,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'unreadCount': unreadCount,
      'lastMessage': lastMessage?.toJson(),
    };
  }
}
