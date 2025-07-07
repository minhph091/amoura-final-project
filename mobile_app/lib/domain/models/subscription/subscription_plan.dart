// Domain model for subscription plans
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationInMonths;
  final List<String> benefits;
  final bool isPopular;
  final double? discountPercentage;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMonths,
    required this.benefits,
    this.isPopular = false,
    this.discountPercentage,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDuration {
    if (durationInMonths == 1) {
      return '1 Month';
    } else if (durationInMonths == 12) {
      return '1 Year';
    } else {
      return '$durationInMonths Months';
    }
  }

  double get monthlyPrice => price / durationInMonths;

  String get formattedMonthlyPrice => '\$${monthlyPrice.toStringAsFixed(2)}/month';

  double? get discountedPrice {
    if (discountPercentage == null) return null;
    return price * (1 - discountPercentage! / 100);
  }

  String? get formattedDiscountedPrice {
    final discounted = discountedPrice;
    if (discounted == null) return null;
    return '\$${discounted.toStringAsFixed(2)}';
  }
}
