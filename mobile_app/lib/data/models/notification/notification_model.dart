// lib/data/models/notification/notification_model.dart

import 'package:flutter/foundation.dart';

// Model thông báo (Notification)
class NotificationModel {
  final String id;
  final String? title;
  final String? content;
  final NotificationType type;
  final String? userId;
  final String? avatar;
  final String? url;
  final int? relatedEntityId;
  final String? relatedEntityType;
  final DateTime? timestamp;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationModel({
    required this.id,
    this.title,
    this.content,
    required this.type,
    this.userId,
    this.avatar,
    this.url,
    this.relatedEntityId,
    this.relatedEntityType,
    this.timestamp,
    this.isRead = false,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'],
      content: json['content'],
      type: notificationTypeFromString(json['type'] ?? ''),
      userId: json['userId']?.toString(),
      avatar: json['avatar'],
      url: json['url'],
      relatedEntityId: json['relatedEntityId'] is int
          ? json['relatedEntityId']
          : int.tryParse(json['relatedEntityId']?.toString() ?? ''),
      relatedEntityType: json['relatedEntityType'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': notificationTypeToString(type),
      'userId': userId,
      'avatar': avatar,
      'url': url,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'timestamp': timestamp?.toIso8601String(),
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      content: content,
      type: type,
      userId: userId,
      avatar: avatar,
      url: url,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Enum loại thông báo (đồng bộ với UI/backend)
enum NotificationType { like, match, message, system, marketing }

NotificationType notificationTypeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'like':
      return NotificationType.like;
    case 'match':
      return NotificationType.match;
    case 'message':
      return NotificationType.message;
    case 'system':
      return NotificationType.system;
    case 'marketing':
      return NotificationType.marketing;
    default:
      return NotificationType.system;
  }
}

String notificationTypeToString(NotificationType type) {
  switch (type) {
    case NotificationType.like:
      return 'like';
    case NotificationType.match:
      return 'match';
    case NotificationType.message:
      return 'message';
    case NotificationType.system:
      return 'system';
    case NotificationType.marketing:
      return 'marketing';
  }
}