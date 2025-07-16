// lib/data/models/user/role_model.dart

// Model vai trò (Role) trong hệ thống
class RoleModel {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });
}
