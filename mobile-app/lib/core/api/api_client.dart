// lib/core/api/api_client.dart

import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: 'http://10.0.2.2:8080/api',
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
          },
        ));

  // Xử lý lỗi chung
  void _handleError(DioException e) {
    if (e.response != null) {
      throw Exception('Error: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }

  // Gửi yêu cầu POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}

// Lớp ngoại lệ tùy chỉnh
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}