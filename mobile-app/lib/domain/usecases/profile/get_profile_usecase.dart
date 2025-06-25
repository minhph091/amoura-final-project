// lib/domain/usecases/profile/get_profile_usecase.dart
import '../../../core/services/profile_service.dart';

class GetProfileUseCase {
  final ProfileService _profileService;

  GetProfileUseCase(this._profileService);

  // Execute the use case to retrieve profile data
  Future<Map<String, dynamic>> execute() async {
    return await _profileService.getProfile();
  }
}