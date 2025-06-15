import 'package:flutter/material.dart';
import '../vip_subscription_view.dart';

class VipUpgradeDialog extends StatelessWidget {
  final String feature;
  final String description;
  final IconData icon;

  const VipUpgradeDialog({
    super.key,
    required this.feature,
    this.description = 'Upgrade to Amoura VIP to use this feature and enjoy many other exclusive benefits.',
    this.icon = Icons.star,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE94057).withValues(alpha: 0.5, red: 0.91, green: 0.25, blue: 0.34),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // VIP Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE94057), Color(0xFFFF5E7D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE94057).withValues(alpha: 0.5, red: 0.91, green: 0.25, blue: 0.34),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            // Feature title
            Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9, red: 1, green: 1, blue: 1),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to VIP subscription page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VipSubscriptionView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94057),
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: const Color(0xFFE94057).withValues(alpha: 0.5, red: 0.91, green: 0.25, blue: 0.34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Nâng cấp lên VIP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Để sau',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show the dialog
  static Future<void> show({
    required BuildContext context,
    required String feature,
    String? description,
    IconData icon = Icons.star,
  }) {
    return showDialog(
      context: context,
      builder: (context) => VipUpgradeDialog(
        feature: feature,
        description: description ?? 'Upgrade to Amoura VIP to use this feature and enjoy many other exclusive benefits.',
        icon: icon,
      ),
    );
  }
}
