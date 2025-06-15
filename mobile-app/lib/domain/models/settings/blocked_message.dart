// filepath: c:\amoura-final-project\mobile-app\lib\domain\models\settings\blocked_message.dart
import 'package:flutter/foundation.dart';

/// Model class representing a blocked message in the application
class BlockedMessage {
  /// Unique identifier for the blocked message
  final String id;

  /// The user's name who sent the blocked message
  final String userName;

  /// The user's age
  final int age;

  /// User's location information
  final String location;

  /// URL to the user's profile photo
  final String userPhotoUrl;

  /// The content of the blocked message
  final String messageContent;

  /// When the message was sent
  final DateTime timestamp;

  /// Unique identifier of the user who sent the message
  final String userId;

  /// The last message in the conversation
  String get lastMessage => messageContent;

  const BlockedMessage({
    required this.id,
    required this.userName,
    required this.age,
    required this.location,
    required this.userPhotoUrl,
    required this.messageContent,
    required this.timestamp,
    required this.userId,
  });

  /// Create a BlockedMessage from JSON data
  factory BlockedMessage.fromJson(Map<String, dynamic> json) {
    return BlockedMessage(
      id: json['id'] as String,
      userName: json['userName'] as String,
      age: json['age'] as int,
      location: json['location'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String,
      messageContent: json['messageContent'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
    );
  }

  /// Convert BlockedMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'age': age,
      'location': location,
      'userPhotoUrl': userPhotoUrl,
      'messageContent': messageContent,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  /// Create a copy of BlockedMessage with optional new values
  BlockedMessage copyWith({
    String? id,
    String? userName,
    int? age,
    String? location,
    String? userPhotoUrl,
    String? messageContent,
    DateTime? timestamp,
    String? userId,
  }) {
    return BlockedMessage(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      age: age ?? this.age,
      location: location ?? this.location,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      messageContent: messageContent ?? this.messageContent,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BlockedMessage &&
      other.id == id &&
      other.userName == userName &&
      other.age == age &&
      other.location == location &&
      other.userPhotoUrl == userPhotoUrl &&
      other.messageContent == messageContent &&
      other.timestamp == timestamp &&
      other.userId == userId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userName.hashCode ^
      age.hashCode ^
      location.hashCode ^
      userPhotoUrl.hashCode ^
      messageContent.hashCode ^
      timestamp.hashCode ^
      userId.hashCode;
  }
}
