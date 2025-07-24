// lib/data/models/chat/chat_room_model.dart

// Model phòng chat (ChatRoom)
class ChatRoomModel {
  final int id;
  final List<int> participantIds; // user_id của các thành viên
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? lastMessageId;

  ChatRoomModel({
    required this.id,
    required this.participantIds,
    required this.createdAt,
    this.updatedAt,
    this.lastMessageId,
  });
}
