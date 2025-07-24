// lib/domain/usecases/auth/login_usecase.dart
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/auth_service.dart';

class LoginUseCase {
  final AuthRepository _authRepository;
  final AuthService _authService;

  LoginUseCase(this._authRepository, this._authService);

  Future<Map<String, dynamic>> execute({
    required String email,
    String? phoneNumber,
    String? password,
    String? otpCode,
    required String loginType,
  }) async {
    final response = await _authRepository.login(
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      otpCode: otpCode,
      loginType: loginType,
    );

    if (response['accessToken'] != null && response['user'] != null) {
      await _authService.saveTokens(
        response['accessToken'],
        response['refreshToken'] ?? '',
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> requestLoginOtp({
    required String email,
  }) async {
    return await _authRepository.requestLoginOtp(email: email);
  }

  Future<bool> checkEmailAvailability(String email) async {
    return await _authRepository.checkEmailAvailability(email);
  }
}
