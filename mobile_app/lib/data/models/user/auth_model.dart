// lib/data/models/user/auth_model.dart

// Model xác thực (AuthResponse)
class AuthModel {
  final String accessToken;
  final String? refreshToken;
  final int userId;
  final DateTime? expiresAt;

  AuthModel({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    this.expiresAt,
  });
}
