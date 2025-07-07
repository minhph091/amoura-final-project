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
      name: 'Monthly',
      description: 'Monthly subscription with all VIP benefits',
      price: 9.99,
      durationInMonths: 1,
      benefits: [
        'Unlimited swipes',
        'See who likes you',
        'Enhanced profile visibility',
        'Priority matching',
      ],
    ),
    SubscriptionPlan(
      id: 'semi_annual',
      name: '6 Months',
      description: '6-month subscription with all VIP benefits',
      price: 49.99,
      durationInMonths: 6,
      isPopular: true,
      discountPercentage: 15,
      benefits: [
        'Unlimited swipes',
        'See who likes you',
        'Enhanced profile visibility',
        'Priority matching',
        'Special event access',
      ],
    ),
    SubscriptionPlan(
      id: 'annual',
      name: 'Annual',
      description: 'Annual subscription with all VIP benefits',
      price: 79.99,
      durationInMonths: 12,
      discountPercentage: 33,
      benefits: [
        'Unlimited swipes',
        'See who likes you',
        'Enhanced profile visibility',
        'Priority matching',
        'Special event access',
        'Exclusive seasonal gifts',
      ],
    ),
  ];

  // Mock subscription features data
  final List<SubscriptionFeature> vipFeatures = [
    SubscriptionFeature(
      id: 'rewind',
      title: 'Unlimited Rewind',
      description: 'Get back to profiles you accidentally swiped left on',
      iconPath: 'assets/icons/rewind.png',
    ),
    SubscriptionFeature(
      id: 'likes',
      title: 'See Who Likes You',
      description: 'See all the people who have already liked your profile',
      iconPath: 'assets/icons/likes.png',
    ),
    SubscriptionFeature(
      id: 'visibility',
      title: 'Enhanced Profile',
      description: 'Make your profile stand out with special highlights',
      iconPath: 'assets/icons/visibility.png',
    ),
    SubscriptionFeature(
      id: 'events',
      title: 'Special Events',
      description: 'Get access to exclusive events and special gifts',
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
      _subscriptionEndDate = DateTime.now().add(Duration(days: 30 * plan.durationInMonths));
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
