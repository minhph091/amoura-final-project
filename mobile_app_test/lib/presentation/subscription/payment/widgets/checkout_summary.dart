import 'package:flutter/material.dart';
import '../../../../domain/models/subscription/subscription_plan.dart';

class CheckoutSummary extends StatelessWidget {
  final SubscriptionPlan plan;
  final String paymentMethod;
  final VoidCallback onEditPaymentMethod;

  const CheckoutSummary({
    super.key,
    required this.plan,
    required this.paymentMethod,
    required this.onEditPaymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Subscription plan details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  plan.formattedDuration,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment method
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                InkWell(
                  onTap: onEditPaymentMethod,
                  child: Row(
                    children: [
                      Text(
                        paymentMethod,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Original price if discount applies
            if (plan.discountPercentage != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Original Price',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    plan.formattedPrice,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

            // Discount if applicable
            if (plan.discountPercentage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Discount',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Text(
                            '${plan.discountPercentage!.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '-${_calculateDiscountAmount(plan)}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Final price line with larger text
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    plan.discountPercentage != null
                        ? plan.formattedDiscountedPrice!
                        : plan.formattedPrice,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Recurring payment note
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Your subscription will automatically renew. You can cancel anytime.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDiscountAmount(SubscriptionPlan plan) {
    if (plan.discountPercentage == null) return '\$0';

    final originalPrice = _extractPriceValue(plan.formattedPrice);
    final discountedPrice = _extractPriceValue(plan.formattedDiscountedPrice!);
    final difference = originalPrice - discountedPrice;

    return '\$${difference.toStringAsFixed(2)}';
  }

  double _extractPriceValue(String formattedPrice) {
    // Remove $ and any other non-numeric characters except decimal point
    final priceString = formattedPrice.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(priceString) ?? 0.0;
  }
}
