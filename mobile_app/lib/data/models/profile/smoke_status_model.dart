// lib/data/models/profile/smoke_status_model.dart

class SmokeStatusModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SmokeStatusModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}
