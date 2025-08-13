// lib/presentation/settings/settings_viewmodel.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../core/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../profile/view/profile_viewmodel.dart';
import '../../infrastructure/services/app_initialization_service.dart';
import '../../infrastructure/services/app_startup_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final LogoutUseCase _logoutUseCase = GetIt.I<LogoutUseCase>();
  final AuthService _authService = GetIt.I<AuthService>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> logout(BuildContext context) async {
    try {
      debugPrint('Starting logout process');
      _isLoading = true;
      notifyListeners();

      String? refreshToken = await _authService.getRefreshToken();
      debugPrint(
        'Retrieved refreshToken: $refreshToken',
      ); // Log giá trị refreshToken
      // Gọi logout với refreshToken, nếu null thì truyền chuỗi rỗng
      await _logoutUseCase.execute(refreshToken ?? '');
      debugPrint(
        'LogoutUseCase executed successfully',
      ); // Log xác nhận gọi API thành công
      await _authService.clearTokens();
      debugPrint('Tokens cleared successfully'); // Log xác nhận xóa token
      
      // Reset AppStartupService để clear cached data
      AppStartupService.instance.reset();
      print('AppStartupService reset successfully');
    } catch (e) {
      debugPrint('Logout failed in SettingsViewModel: $e'); // Log lỗi chi tiết
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint(
        'Logout process completed, isLoading set to false',
      ); // Log xác nhận hoàn thành
      Provider.of<ProfileViewModel>(context, listen: false).clearProfile();
    }
  }
}
