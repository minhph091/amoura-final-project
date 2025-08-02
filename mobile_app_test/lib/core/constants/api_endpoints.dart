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
  static const String verifyPasswordResetOtp = '/auth/password/reset/verify-otp';
  static const String resetPassword = '/auth/password/reset';
  static const String resendPasswordResetOtp = '/auth/password/reset/resend-otp';
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
  
  // Helper methods for getting user photos by userId
  static String getUserAvatar(String userId) => '/profiles/photos/$userId/avatar';
  static String getUserCover(String userId) => '/profiles/photos/$userId/cover';
  static String getUserHighlights(String userId) => '/profiles/photos/$userId/highlights';

  static const String user = '/user';

  static const String changeEmailRequest = '/user/change-email/request';
  static const String changeEmailConfirm = '/user/change-email/confirm';

  // Matching endpoints
  static const String getRecommendations = '/matching/recommendations';
  static const String swipeUser = '/matching/swipe';
  static const String getMatches = '/matching/matches';

  // Chat endpoints
  static const String chatRooms = '/chat/rooms';
  static const String chatMessages = '/chat/messages';
  static const String chatUploadImage = '/chat/upload-image';
  static const String chatDeleteImage = '/chat/delete-image';
  
  // Helper methods for chat endpoints with parameters
  static String chatRoomById(String chatRoomId) => '$chatRooms/$chatRoomId';
  static String chatMessagesByRoom(String chatRoomId) => '$chatRooms/$chatRoomId/messages';
  static String markMessagesAsRead(String chatRoomId) => '$chatRooms/$chatRoomId/messages/read';
  static String unreadMessageCount(String chatRoomId) => '$chatRooms/$chatRoomId/messages/unread-count';
  static String deleteMessageForMe(String messageId) => '$chatMessages/$messageId/delete-for-me';
  static String recallMessage(String messageId) => '$chatMessages/$messageId/recall';
}
