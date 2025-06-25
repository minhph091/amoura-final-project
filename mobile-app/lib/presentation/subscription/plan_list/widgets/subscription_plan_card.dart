import 'package:flutter/material.dart';
import '../../../../domain/models/subscription/subscription_plan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double>? animation;

  const SubscriptionPlanCard({
    Key? key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidget = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      elevation: isSelected ? 6 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
            )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Popular badge if applicable
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),

              // Plan name
              Text(
                plan.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                plan.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Price section
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Main price
                  if (plan.discountPercentage != null)
                    Text(
                      plan.formattedPrice,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),

                  if (plan.discountPercentage != null)
                    const SizedBox(width: 8),

                  Text(
                    plan.discountPercentage != null
                        ? plan.formattedDiscountedPrice!
                        : plan.formattedPrice,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Monthly price
              Text(
                plan.formattedMonthlyPrice,
                style: Theme.of(context).textTheme.bodySmall,
              ),

              // Discount badge
              if (plan.discountPercentage != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade400),
                  ),
                  child: Text(
                    'SAVE ${plan.discountPercentage!.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Apply animation if provided
    if (animation != null) {
      return ScaleTransition(
        scale: animation!,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}
