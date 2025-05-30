// lib/data/models/chat/message_model.dart

// Model tin nhắn (Message)
class MessageModel {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final int messageTypeId;
  final bool isRead;
  final DateTime? readAt;
  final bool isEdited;
  final DateTime? editedAt;
  final bool isRecalled;
  final DateTime? recalledAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageTypeId,
    required this.isRead,
    this.readAt,
    required this.isEdited,
    this.editedAt,
    required this.isRecalled,
    this.recalledAt,
    required this.createdAt,
    this.updatedAt,
  });
}