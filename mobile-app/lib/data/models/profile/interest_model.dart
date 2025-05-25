// lib/data/models/profile/interest_model.dart

class InterestModel {
  final int id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InterestModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });
}