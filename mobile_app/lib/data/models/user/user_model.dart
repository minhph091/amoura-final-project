// lib/data/models/user/user_model.dart

// Model người dùng (User) bám sát bảng users từ database
class UserModel {
  final int id;
  final String username;
  final String? passwordHash;
  final String email;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;
  final int? roleId;
  final UserStatus status;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    this.passwordHash,
    required this.email,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.roleId,
    required this.status,
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });
}

// Enum trạng thái user
enum UserStatus { active, inactive, suspend }

UserStatus userStatusFromString(String value) {
  switch (value) {
    case 'active':
      return UserStatus.active;
    case 'inactive':
      return UserStatus.inactive;
    case 'suspend':
      return UserStatus.suspend;
    default:
      return UserStatus.inactive;
  }
}