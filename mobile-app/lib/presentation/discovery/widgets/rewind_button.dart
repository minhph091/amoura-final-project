import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../infrastructure/services/subscription_service.dart';
import '../../subscription/utils/vip_feature_guard.dart';

class RewindButton extends StatelessWidget {
  final VoidCallback onRewind;

  const RewindButton({
    super.key,
    required this.onRewind,
  });

  Future<void> _handleRewindTap(BuildContext context, SubscriptionService subscriptionService) async {
    final hasAccess = await VipFeatureGuard.checkAccess(
      context,
      subscriptionService,
      featureTitle: 'Go Back to Skipped Profiles',
      featureId: 'rewind_profiles',
      description: 'Upgrade to Amoura VIP to go back to profiles you accidentally skipped!',
      icon: Icons.replay,
    );

    if (hasAccess && context.mounted) {
      onRewind();
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Provider.of<SubscriptionService>(context);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _handleRewindTap(context, subscriptionService),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.replay,
              size: 28,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
