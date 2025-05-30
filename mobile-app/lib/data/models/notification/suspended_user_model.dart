// lib/data/models/notification/suspended_user_model.dart

// Model người dùng bị đình chỉ (SuspendedUser)
class SuspendedUserModel {
  final int id;
  final int userId;
  final int reportId;
  final int? suspensionPeriod;
  final DateTime suspendedAt;

  SuspendedUserModel({
    required this.id,
    required this.userId,
    required this.reportId,
    this.suspensionPeriod,
    required this.suspendedAt,
  });
}