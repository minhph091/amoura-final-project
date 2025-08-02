// filepath: C:\amoura-final-project\mobile-app\lib\domain\models\subscription\subscription_feature.dart
class SubscriptionFeature {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final bool vipOnly;

  SubscriptionFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    this.vipOnly = true,
  });
}
