// lib/data/repositories/auth_repository.dart
import '../remote/auth_api.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  final AuthApi _authApi;
  final AuthService _authService;

  AuthRepository(this._authApi, this._authService);

  Future<void> logout(String refreshToken) async {
    await _authApi.logout(refreshToken);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await _authApi.refreshToken(refreshToken);
  }

  Future<Map<String, dynamic>> initiateRegistration({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return await _authApi.initiateRegistration(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionToken,
    required String otpCode,
  }) async {
    return await _authApi.verifyOtp(
      sessionToken: sessionToken,
      otpCode: otpCode,
    );
  }

  Future<Map<String, dynamic>> completeRegistration({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String sex,
  }) async {
    return await _authApi.completeRegistration(
      sessionToken: sessionToken,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      sex: sex,
    );
  }

  Future<Map<String, dynamic>> resendOtp({required String sessionToken}) async {
    return await _authApi.resendOtp(sessionToken: sessionToken);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String sessionToken,
    required Map<String, dynamic> profileData,
  }) async {
    return await _authApi.updateProfile(
      sessionToken: sessionToken,
      profileData: profileData,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    String? phoneNumber,
    String? password,
    String? otpCode,
    required String loginType,
  }) async {
    return await _authApi.login(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      otpCode: otpCode,
      loginType: loginType,
    );
  }

  Future<Map<String, dynamic>> requestLoginOtp({
    required String email,
  }) async {
    return await _authApi.requestLoginOtp(email: email);
  }

  Future<bool> checkEmailAvailability(String email) async {
    return await _authApi.checkEmailAvailability(email);
  }

  Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    return await _authApi.requestPasswordReset(email: email);
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otpCode,
    required String newPassword,
  }) async {
    return await _authApi.resetPassword(
      email: email,
      otpCode: otpCode,
      newPassword: newPassword,
    );
  }
}