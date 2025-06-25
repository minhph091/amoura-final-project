import 'package:flutter/material.dart';
import '../../../infrastructure/services/subscription_service.dart';
import '../widgets/vip_promotion_dialog.dart';

class VipFeatureGuard {
  static Future<bool> checkAccess(
    BuildContext context,
    SubscriptionService subscriptionService, {
    required String featureTitle,
    required String featureId,
    required String description,
    required IconData icon,
  }) async {
    // If user already has VIP access, return true immediately
    if (subscriptionService.isVip) {
      return true;
    }

    // Otherwise, show the VIP promotion dialog and return the result
    final result = await VipPromotionDialog.show(
      context,
      featureTitle: featureTitle,
      featureId: featureId,
      description: description,
      icon: icon,
    );

    // Return false if the user dismissed the dialog or clicked "Not now"
    return result ?? false;
  }
}
