// lib/data/models/profile/job_industry_model.dart

class JobIndustryModel {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JobIndustryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    this.updatedAt,
  });
}
