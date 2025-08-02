// lib/data/models/call/call_model.dart

// Model cuộc gọi (Call)
class CallModel {
  final int id;
  final int callerId;
  final int receiverId;
  final CallType type;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // ringing, ongoing, ended, missed, declined
  final DateTime createdAt;

  CallModel({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    this.startTime,
    this.endTime,
    required this.status,
    required this.createdAt,
  });
}

enum CallType { voice, video }

CallType callTypeFromString(String value) {
  switch (value) {
    case 'voice':
      return CallType.voice;
    case 'video':
      return CallType.video;
    default:
      return CallType.voice;
  }
}
