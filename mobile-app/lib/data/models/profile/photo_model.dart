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
}