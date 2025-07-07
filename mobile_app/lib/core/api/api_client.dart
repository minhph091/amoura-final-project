// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../config/environment.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import 'dart:io';

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
          // Check if this is a login error
          final data = e.response?.data as Map<String, dynamic>?;
          final errorCode = data?['errorCode'] as String?;
          
          if (errorCode == 'INVALID_CREDENTIALS') {
            // This is a login error, don't try to refresh token
            return handler.next(e);
          }
          
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

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.delete(path, queryParameters: queryParameters);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> uploadMultipart(
    String path, {
    required String fileField,
    required String filePath,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final file = File(filePath);
      final fileName = filePath.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      
      // Map file extensions to MIME types
      final mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'gif': 'image/gif',
        'webp': 'image/webp',
      };
      
      final mimeType = mimeTypes[extension] ?? 'image/jpeg';
      final contentType = MediaType.parse(mimeType);
      
      final formDataMap = <String, dynamic>{
        fileField: await MultipartFile.fromFile(
          filePath,
          filename: fileName,
          contentType: contentType,
        ),
      };

      // Add additional data to form
      if (additionalData != null) {
        formDataMap.addAll(additionalData);
      }

      final formData = FormData.fromMap(formDataMap);

      return await dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            // Chat upload API returns plain text, not JSON
            'Accept': path.contains('chat/upload-image') ? 'text/plain' : 'application/json',
          },
          // Disable automatic JSON parsing for chat upload
          responseType: path.contains('chat/upload-image') ? ResponseType.plain : ResponseType.json,
        ),
      );
    } on DioException {
      rethrow;
    }
  }
}