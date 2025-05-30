// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import '../../config/environment.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';

class ApiClient {
  final Dio dio;
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  ApiClient({
    required AuthService authService,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _authService = authService,
        _navigatorKey = navigatorKey,
        dio = Dio(BaseOptions(
          baseUrl: EnvironmentConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _authService.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          try {
            // Lấy RefreshTokenUseCase từ GetIt khi cần
            final refreshTokenUseCase = GetIt.instance<RefreshTokenUseCase>();
            await refreshTokenUseCase.execute();
            String? newAccessToken = await _authService.getAccessToken();
            if (newAccessToken == null) {
              throw Exception('Failed to retrieve new access token after refresh');
            }
            e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            return handler.resolve(await dio.fetch(e.requestOptions));
          } catch (refreshError) {
            await _authService.clearTokens();
            if (_navigatorKey.currentContext != null) {
              Navigator.pushNamedAndRemoveUntil(
                _navigatorKey.currentContext!,
                AppRoutes.welcome,
                (route) => false,
              );
            }
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      throw Exception('Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}