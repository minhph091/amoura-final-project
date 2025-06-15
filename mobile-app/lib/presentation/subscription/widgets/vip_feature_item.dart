import 'package:flutter/material.dart';
import '../../../domain/models/subscription/subscription_feature.dart';

class VipFeatureItem extends StatelessWidget {
  final SubscriptionFeature feature;
  final bool isSelected;
  final VoidCallback onTap;

  const VipFeatureItem({
    super.key,
    required this.feature,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Feature icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForFeature(feature.id),
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Feature title
            Expanded(
              child: Text(
                feature.title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // VIP badge for premium features
            if (feature.vipOnly)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.purple.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  'VIP',
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForFeature(String featureId) {
    switch (featureId) {
      case 'rewind':
        return Icons.replay_rounded;
      case 'unlimited_likes':
        return Icons.favorite;
      case 'see_likes':
        return Icons.visibility;
      case 'priority_matches':
        return Icons.bolt;
      case 'global_mode':
        return Icons.public;
      default:
        return Icons.star;
    }
  }
}
