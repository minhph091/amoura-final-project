// lib/data/models/profile/education_level_model.dart

class EducationLevelModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EducationLevelModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}
