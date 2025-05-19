// lib/data/models/profile/drink_status_model.dart

class DrinkStatusModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DrinkStatusModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}