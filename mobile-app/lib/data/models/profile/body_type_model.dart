// lib/data/models/profile/body_type_model.dart

class BodyTypeModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BodyTypeModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}