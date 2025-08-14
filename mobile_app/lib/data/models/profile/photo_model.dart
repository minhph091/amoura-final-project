// lib/data/models/profile/photo_model.dart

import '../../../config/environment.dart';
import '../../../core/utils/url_transformer.dart';

// Model ảnh người dùng (Photo)
class PhotoModel {
  final int id;
  final int userId;
  final String path;
  final String type; // profile, gallery
  final DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.path,
    required this.type,
    required this.createdAt,
  });

  /// Get the raw URL from server (without transformation)
  String get rawUrl {
    if (path.startsWith('http')) return path;
    String base = EnvironmentConfig.baseUrl;
    // Xóa /api ở cuối nhưng không làm mất dấu /
    base = base.replaceFirst(RegExp(r'/api/?$'), '');
    if (base.endsWith('/')) base = base.substring(0, base.length - 1);
    String fixedPath = path;
    // Nếu path chưa có prefix /api/files thì thêm vào
    if (!fixedPath.startsWith('/api/files')) {
      if (fixedPath.startsWith('/')) {
        fixedPath = '/api/files$fixedPath';
      } else {
        fixedPath = '/api/files/$fixedPath';
      }
    }
    final url = base + fixedPath;
    assert(url.startsWith('http'), 'PhotoModel.rawUrl: URL không hợp lệ: $url (base: $base, fixedPath: $fixedPath)');
    return url;
  }

  /// Get the transformed URL for display (localhost -> 10.0.2.2)
  String get displayUrl {
    return UrlTransformer.transform(rawUrl);
  }

  /// Get the URL for caching purposes (same as displayUrl)
  String get cacheUrl {
    return displayUrl;
  }

  /// Legacy getter (returns displayUrl for backward compatibility)
  String get url {
    return displayUrl;
  }

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int,
      userId: json['userId'] as int? ?? 0,
      path: json['url'] as String? ?? json['path'] as String? ?? '',
      type: json['type'] as String? ?? 'profile',
      createdAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'url': path,
      'type': type,
      'uploadedAt': createdAt.toIso8601String(),
    };
  }
}
