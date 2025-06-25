import 'package:dio/dio.dart';
import '../../../data/models/user/auth_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/api/api_exception.dart';

class RefreshTokenUseCase {
  final AuthRepository _authRepository;
  final AuthService _authService;

  RefreshTokenUseCase(this._authRepository, this._authService);

  Future<AuthModel> execute() async {
    try {
      String? refreshToken = await _authService.getRefreshToken();
      if (refreshToken == null) {
        print('No refresh token available in RefreshTokenUseCase');
        throw ApiException('No refresh token available');
      }
      print('Calling /auth/refresh with refreshToken: $refreshToken');

      final response = await _authRepository.refreshToken(refreshToken);
      print('Received response from /auth/refresh: $response');

      final String? accessToken = response['accessToken'] as String?;
      final String? newRefreshToken = response['refreshToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw ApiException('No access token returned from refresh');
      }
      if (newRefreshToken == null || newRefreshToken.isEmpty) {
        throw ApiException('No refresh token returned from refresh');
      }

      final authModel = AuthModel(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        userId: response['user']['id'],
        expiresAt: DateTime.now().add(const Duration(seconds: 3600)),
      );

      await _authService.saveTokens(authModel.accessToken, authModel.refreshToken!);
      print('Tokens saved after refresh: accessToken=${authModel.accessToken}, refreshToken=${authModel.refreshToken}');

      return authModel;
    } on DioException catch (e) {
      print('Error in RefreshTokenUseCase: ${_handleDioError(e)}');
      throw ApiException(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data as Map<String, dynamic>?;
      final message = data?['message'] ?? 'Unknown error';
      return message;
    }
    return 'Network error. Please check your connection and try again.';
  }
}