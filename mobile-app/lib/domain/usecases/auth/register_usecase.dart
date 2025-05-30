// lib/domain/usecases/auth/register_usecase.dart
import '../../../data/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

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
    return await _authRepository.completeRegistration(
      sessionToken: sessionToken,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      sex: sex,
    );
  }

  Future<Map<String, dynamic>> resendOtp({required String sessionToken}) async {
    return await _authRepository.resendOtp(sessionToken: sessionToken);
  }
}