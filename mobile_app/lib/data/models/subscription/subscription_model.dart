// lib/data/models/subscription/subscription_model.dart

// Model gói VIP (Subscription Plan)
class SubscriptionPlanModel {
  final int id;
  final String name;
  final double priceMonthly;
  final double priceYearly;
  final String? description;
  final String? features;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    this.description,
    this.features,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });
}