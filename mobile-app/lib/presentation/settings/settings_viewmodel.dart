// lib/presentation/settings/settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../core/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../profile/view/profile_viewmodel.dart';

class SettingsViewModel extends ChangeNotifier {
  final LogoutUseCase _logoutUseCase = GetIt.I<LogoutUseCase>();
  final AuthService _authService = GetIt.I<AuthService>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> logout(BuildContext context) async {
    try {
      print('Starting logout process');
      _isLoading = true;
      notifyListeners();

      String? refreshToken = await _authService.getRefreshToken();
      print('Retrieved refreshToken: $refreshToken'); // Log giá trị refreshToken
      // Gọi logout với refreshToken, nếu null thì truyền chuỗi rỗng
      await _logoutUseCase.execute(refreshToken ?? '');
      print('LogoutUseCase executed successfully'); // Log xác nhận gọi API thành công
      await _authService.clearTokens(); // Đảm bảo xóa token cục bộ
      print('Tokens cleared successfully'); // Log xác nhận xóa token
    } catch (e) {
      print('Logout failed in SettingsViewModel: $e'); // Log lỗi chi tiết
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Logout process completed, isLoading set to false'); // Log xác nhận hoàn thành
      Provider.of<ProfileViewModel>(context, listen: false).clearProfile();
    }
  }
}