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

  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
