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
  static const String refreshToken = '/auth/refresh';

  static const String profileOptions = '/profiles/options';
  static const String uploadAvatar = '/profiles/photos/avatar';
  static const String uploadCover = '/profiles/photos/cover';
  static const String uploadHighlights = '/profiles/photos/highlights';
  static const String updateProfile = '/profiles/me';
  static const String deleteAvatar = '/profiles/photos/avatar';
  static const String deleteCover = '/profiles/photos/cover';
  static const String highlightsBase = '/profiles/photos/highlights';
  
  // Helper method for delete highlight with photoId
  static String deleteHighlight(int photoId) => '$highlightsBase/$photoId';

  static const String user = '/user';

  static const String changeEmailRequest = '/user/change-email/request';
  static const String changeEmailConfirm = '/user/change-email/confirm';

  // Matching endpoints
  static const String getRecommendations = '/matching/recommendations';
  static const String swipeUser = '/matching/swipe';
  static const String getMatches = '/matching/matches';
}