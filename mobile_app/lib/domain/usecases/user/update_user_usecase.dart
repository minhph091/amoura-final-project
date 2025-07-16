import '../../../data/repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository _userRepository;
  UpdateUserUseCase(this._userRepository);

  Future<Map<String, dynamic>> execute({
    required Map<String, dynamic> userData,
  }) async {
    return await _userRepository.updateUser(userData);
  }
}
