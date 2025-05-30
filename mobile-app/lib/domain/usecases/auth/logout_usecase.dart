// lib/domain/usecases/auth/logout_usecase.dart
import '../../../data/repositories/auth_repository.dart'; 
import '../../../core/services/auth_service.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;
  final AuthService _authService;

  LogoutUseCase(this._authRepository, this._authService);

  Future<void> execute(String refreshToken) async {
    await _authRepository.logout(refreshToken);
    await _authService.clearTokens();
  }
}