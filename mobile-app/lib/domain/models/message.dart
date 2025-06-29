import 'package:flutter/foundation.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;
  final MessageType type;
  final String? mediaUrl;
  final String? fileInfo;
  final String? replyToMessageId;
  final String? replyToMessage;
  final String? replyToSenderName;
  final bool isEdited;
  final DateTime? editedAt;
  final Map<String, String> reactions;
  final bool isPinned;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? updatedAt;
  final String? imageUrl;
  final String? imageUploaderId;
  final bool recalled;
  final DateTime? recalledAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.mediaUrl,
    this.fileInfo,
    this.replyToMessageId,
    this.replyToMessage,
    this.replyToSenderName,
    this.isEdited = false,
    this.editedAt,
    this.reactions = const {},
    this.isPinned = false,
    this.isRead = false,
    this.readAt,
    this.updatedAt,
    this.imageUrl,
    this.imageUploaderId,
    this.recalled = false,
    this.recalledAt,
  });

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? content,
    DateTime? timestamp,
    MessageStatus? status,
    MessageType? type,
    String? mediaUrl,
    String? fileInfo,
    String? replyToMessageId,
    String? replyToMessage,
    String? replyToSenderName,
    bool? isEdited,
    DateTime? editedAt,
    Map<String, String>? reactions,
    bool? isPinned,
    bool? isRead,
    DateTime? readAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? imageUploaderId,
    bool? recalled,
    DateTime? recalledAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileInfo: fileInfo ?? this.fileInfo,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUploaderId: imageUploaderId ?? this.imageUploaderId,
      recalled: recalled ?? this.recalled,
      recalledAt: recalledAt ?? this.recalledAt,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    debugPrint('Message.fromJson: Parsing message with data: $json');
    
    final senderId = json['senderId']?.toString() ?? json['sender']?['id']?.toString() ?? '';
    final senderName = json['senderName'] ?? 
                      json['sender']?['name'] ?? 
                      json['sender']?['firstName'] ?? 
                      json['sender']?['username'] ?? 
                      'Unknown User';
    final content = json['content'] ?? json['message'] ?? '';
    
    debugPrint('Message.fromJson: senderId=$senderId, senderName=$senderName, content=$content');
    
    return Message(
      id: json['id']?.toString() ?? json['messageId']?.toString() ?? '',
      chatId: json['chatRoomId']?.toString() ?? json['chatId']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      senderAvatar: json['senderAvatar'] ?? json['sender']?['avatar'],
      content: content,
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now(),
      status: MessageStatus.sent, // Backend doesn't provide status
      type: _parseMessageType(json['messageType'] ?? json['type']),
      mediaUrl: json['imageUrl'], // Use imageUrl from backend
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      imageUrl: json['imageUrl'],
      imageUploaderId: json['imageUploaderId']?.toString(),
      recalled: json['recalled'] ?? false,
      recalledAt: json['recalledAt'] != null 
          ? DateTime.parse(json['recalledAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatRoomId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'messageType': type.name,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': timestamp.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'imageUploaderId': imageUploaderId,
      'recalled': recalled,
      'recalledAt': recalledAt?.toIso8601String(),
    };
  }

  static MessageType _parseMessageType(dynamic messageType) {
    if (messageType == null) return MessageType.text;
    
    final typeString = messageType.toString().toUpperCase();
    switch (typeString) {
      case 'TEXT':
        return MessageType.text;
      case 'IMAGE':
        return MessageType.image;
      case 'VIDEO':
        return MessageType.video;
      case 'AUDIO':
        return MessageType.audio;
      case 'FILE':
        return MessageType.file;
      case 'EMOJI':
        return MessageType.emoji;
      case 'SYSTEM':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  emoji,
  system,
}
