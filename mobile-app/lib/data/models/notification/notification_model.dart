// lib/data/models/notification/notification_model.dart

// Model thông báo (Notification)
class NotificationModel {
  final int id;
  final int userId;
  final NotificationType type;
  final String content;
  final int? relatedEntityId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.relatedEntityId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.updatedAt,
  });
}

// Enum loại thông báo
enum NotificationType { message, match, marketing }

NotificationType notificationTypeFromString(String value) {
  switch (value) {
    case 'message':
      return NotificationType.message;
    case 'matches':
      return NotificationType.match;
    case 'marketing':
      return NotificationType.marketing;
    default:
      return NotificationType.message;
  }
}