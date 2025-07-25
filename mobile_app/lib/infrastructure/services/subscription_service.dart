import 'package:flutter/material.dart';
import '../../../domain/models/subscription/subscription_plan.dart';
import '../../../domain/models/subscription/subscription_feature.dart';

class SubscriptionService with ChangeNotifier {
  bool _isVip = false;
  DateTime? _subscriptionEndDate;

  bool get isVip => _isVip;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;

  // Mock subscription plans data
  final List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: 'monthly',
      name: 'plan_monthly',
      description: 'plan_monthly_desc',
      price: 9.99,
      durationInMonths: 1,
      benefits: [
        'benefit_unlimited_swipes',
        'benefit_see_who_likes_you',
        'benefit_enhanced_profile_visibility',
        'benefit_priority_matching',
      ],
    ),
    SubscriptionPlan(
      id: 'semi_annual',
      name: 'plan_6_months',
      description: 'plan_6_months_desc',
      price: 49.99,
      durationInMonths: 6,
      isPopular: true,
      discountPercentage: 15,
      benefits: [
        'benefit_unlimited_swipes',
        'benefit_see_who_likes_you',
        'benefit_enhanced_profile_visibility',
        'benefit_priority_matching',
        'benefit_special_event_access',
      ],
    ),
    SubscriptionPlan(
      id: 'annual',
      name: 'plan_annual',
      description: 'plan_annual_desc',
      price: 79.99,
      durationInMonths: 12,
      discountPercentage: 33,
      benefits: [
        'benefit_unlimited_swipes',
        'benefit_see_who_likes_you',
        'benefit_enhanced_profile_visibility',
        'benefit_priority_matching',
        'benefit_special_event_access',
        'benefit_exclusive_seasonal_gifts',
      ],
    ),
  ];

  // Mock subscription features data
  final List<SubscriptionFeature> vipFeatures = [
    SubscriptionFeature(
      id: 'rewind',
      title: 'feature_unlimited_rewind',
      description: 'feature_unlimited_rewind_desc',
      iconPath: 'assets/icons/rewind.png',
    ),
    SubscriptionFeature(
      id: 'likes',
      title: 'feature_see_who_likes_you',
      description: 'feature_see_who_likes_you_desc',
      iconPath: 'assets/icons/likes.png',
    ),
    SubscriptionFeature(
      id: 'visibility',
      title: 'feature_enhanced_profile',
      description: 'feature_enhanced_profile_desc',
      iconPath: 'assets/icons/visibility.png',
    ),
    SubscriptionFeature(
      id: 'events',
      title: 'feature_special_events',
      description: 'feature_special_events_desc',
      iconPath: 'assets/icons/gifts.png',
    ),
  ];

  // This would normally come from an API or local storage
  Future<void> checkSubscriptionStatus() async {
    // Mock implementation - in a real app this would check with backend
    _isVip = false;
    _subscriptionEndDate = null;
    notifyListeners();
  }

  // This would call the API to purchase a subscription
  Future<bool> purchaseSubscription(SubscriptionPlan plan) async {
    try {
      // Mock implementation - in a real app this would call payment processing
      _isVip = true;
      _subscriptionEndDate = DateTime.now().add(
        Duration(days: 30 * plan.durationInMonths),
      );
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // For testing/development purposes
  void toggleVipStatus() {
    _isVip = !_isVip;
    if (_isVip) {
      _subscriptionEndDate = DateTime.now().add(const Duration(days: 30));
    } else {
      _subscriptionEndDate = null;
    }
    notifyListeners();
  }
}
