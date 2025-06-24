// lib/data/models/user/login_request.dart

// Model request đăng nhập (LoginRequest)
class LoginRequest {
  final String emailOrPhone;
  final String password;

  LoginRequest({
    required this.emailOrPhone,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'email_or_phone': emailOrPhone,
    'password': password,
  };
}