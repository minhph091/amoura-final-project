// lib/data/models/profile/photo_model.dart

import '../../../config/environment.dart';

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

  /// Get the full URL for the photo
  String get url {
    if (path.startsWith('http')) return path;
    String base = EnvironmentConfig.baseUrl;
    if (base.endsWith('/api')) base = base.replaceFirst('/api', '');
    String fixedPath = path;
    // Nếu path chưa có prefix /api/files thì thêm vào
    if (!fixedPath.startsWith('/api/files')) {
      // Nếu path đã có dấu / đầu thì chỉ thêm 'api/files' vào sau domain
      if (fixedPath.startsWith('/')) {
        fixedPath = '/api/files' + fixedPath;
      } else {
        fixedPath = '/api/files/' + fixedPath;
      }
    }
    return base + fixedPath;
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