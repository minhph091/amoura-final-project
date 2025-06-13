import '../remote/user_api.dart';

class UserRepository {
  final UserApi _userApi;
  UserRepository(this._userApi);

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> userData) async {
    return await _userApi.updateUser(userData);
  }

  // Thêm hàm đổi mật khẩu, gọi API thực tế
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _userApi.changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }
}