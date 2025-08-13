// lib/domain/usecases/auth/update_profile_usecase.dart
import '../../../data/repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  Future<Map<String, dynamic>> execute({
    required String sessionToken,
    required Map<String, dynamic> profileData,
  }) async {
    return await _authRepository.updateProfile(
      sessionToken: sessionToken,
      profileData: profileData,
    );
  }
}
