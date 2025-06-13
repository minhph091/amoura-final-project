import '../remote/user_api.dart';

class UserRepository {
  final UserApi _userApi;
  UserRepository(this._userApi);

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    return await _userApi.updateUser(userData);
  }
}