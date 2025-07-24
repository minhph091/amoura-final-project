// This file contains the API endpoint configurations for the application.

class ApiConfig {
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String loginWithEmailOtp = '/auth/login/email-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resendOtp = '/auth/resend-otp';
  static const String completeRegistration = '/auth/complete-registration';
}
