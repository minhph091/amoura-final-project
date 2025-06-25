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
    );
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
}
