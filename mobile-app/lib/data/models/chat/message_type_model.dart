// lib/data/models/chat/message_type_model.dart

// Model loại tin nhắn (MessageType)
class MessageTypeModel {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MessageTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });
}