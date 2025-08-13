// lib/domain/usecases/auth/register_usecase.dart
import 'package:flutter/foundation.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/auth_service.dart';
import 'package:get_it/get_it.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;
  final AuthService _authService;

  RegisterUseCase(this._authRepository, [AuthService? authService])
      : _authService = authService ?? GetIt.I<AuthService>();

  Future<Map<String, dynamic>> initiate({
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return await _authRepository.initiateRegistration(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String sessionToken,
    required String otpCode,
  }) async {
    return await _authRepository.verifyOtp(
      sessionToken: sessionToken,
      otpCode: otpCode,
    );
  }

  Future<Map<String, dynamic>> complete({
    required String sessionToken,
    required String firstName,
    required String lastName,
    required String dateOfBirth,
    required String sex,
  }) async {
    final response = await _authRepository.completeRegistration(
      sessionToken: sessionToken,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      sex: sex,
    );
    // Log response để kiểm tra token
    debugPrint('Complete registration response: $response');
    // Save tokens if present
    if (response['authResponse'] != null &&
        response['authResponse']['accessToken'] != null &&
        response['authResponse']['refreshToken'] != null) {
      await _authService.saveTokens(
        response['authResponse']['accessToken'],
        response['authResponse']['refreshToken'],
      );
      debugPrint('Tokens saved successfully: accessToken=${response['authResponse']['accessToken']}');
    } else {
      debugPrint('Warning: No tokens found in authResponse');
    }
    return response;
  }

  Future<Map<String, dynamic>> resendOtp({required String sessionToken}) async {
    return await _authRepository.resendOtp(sessionToken: sessionToken);
  }
}
