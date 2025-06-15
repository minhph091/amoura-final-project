import 'package:flutter/material.dart';
import '../../../../domain/models/subscription/subscription_feature.dart';

class VipFeatureCard extends StatelessWidget {
  final SubscriptionFeature feature;
  final bool isHighlighted;

  const VipFeatureCard({
    super.key,
    required this.feature,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isHighlighted
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      elevation: isHighlighted ? 4 : 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feature icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  feature.iconPath,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    _getIconForFeature(feature.id),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Feature details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isHighlighted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            // VIP badge
            if (feature.vipOnly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade300, Colors.pink.shade300],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFeature(String featureId) {
    // Return appropriate icons based on feature ID
    switch (featureId) {
      case 'rewind':
        return Icons.replay_rounded;
      case 'likes':
        return Icons.favorite;
      case 'visibility':
        return Icons.visibility;
      case 'events':
        return Icons.card_giftcard;
      default:
        return Icons.star;
    }
  }
}
