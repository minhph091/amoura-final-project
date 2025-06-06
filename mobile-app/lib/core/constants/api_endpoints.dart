// lib/core/constants/api_endpoints.dart
class ApiEndpoints {
  static const String initiateRegistration = '/auth/register/initiate';
  static const String verifyOtp = '/auth/register/verify-otp';
  static const String completeRegistration = '/auth/register/complete';
  static const String resendOtp = '/auth/register/resend-otp';
  static const String updateProfileAuth = '/auth/profile/update';
  static const String login = '/auth/login';
  static const String requestLoginOtp = '/auth/login/otp/request';
  static const String checkEmailAvailability = '/auth/email-available';
  static const String requestPasswordReset = '/auth/password/reset/request';
  static const String resetPassword = '/auth/password/reset';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh'; // Thêm endpoint này

  static const String profileOptions = '/profiles/options';
  static const String uploadAvatar = '/profiles/photos/avatar';
  static const String uploadCover = '/profiles/photos/cover';
  static const String updateProfile = '/profiles/me';
}