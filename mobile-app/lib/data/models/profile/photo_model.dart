// lib/data/models/profile/photo_model.dart

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
  String get url => path.startsWith('http') ? path : 'https://example.com$path';

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