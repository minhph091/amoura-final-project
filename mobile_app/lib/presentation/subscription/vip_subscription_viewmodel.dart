import 'package:flutter/material.dart';

// VIP Plan model class definition
class VipPlan {
  final String id;
  final String name;
  final double price;
  final double perMonth;
  final int savePercent;
  final String description;
  final List<String> features;
  final bool isPopular;

  VipPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.perMonth,
    required this.savePercent,
    required this.description,
    required this.features,
    this.isPopular = false,
  });
}

class VipSubscriptionViewModel extends ChangeNotifier {
  String _selectedPlanId = 'monthly'; // Default selected plan

  String get selectedPlanId => _selectedPlanId;

  final List<VipPlan> plans = [
    VipPlan(
      id: 'monthly',
      name: '1 Month',
      price: 9.99,
      perMonth: 9.99,
      savePercent: 0,
      description: 'Monthly subscription, cancel anytime',
      features: ['Full Amoura VIP benefits', 'Basic priority in discovery'],
    ),
    VipPlan(
      id: 'biannual',
      name: '6 Months',
      price: 39.99,
      perMonth: 6.67,
      savePercent: 33,
      description: '6-month subscription with significant savings',
      features: [
        'Full Amoura VIP benefits',
        'Medium priority in discovery',
        'Special seasonal gifts',
      ],
      isPopular: true,
    ),
    VipPlan(
      id: 'annual',
      name: '12 Months',
      price: 59.99,
      perMonth: 5.00,
      savePercent: 50,
      description: 'Our best value annual subscription',
      features: [
        'Full Amoura VIP benefits',
        'Highest priority in discovery',
        'Special seasonal gifts',
        'Exclusive profile badge',
      ],
    ),
  ];

  // Get the currently selected plan
  VipPlan? get selectedPlan => plans.firstWhere((plan) => plan.id == _selectedPlanId);

  // Select a different plan
  void selectPlan(String planId) {
    _selectedPlanId = planId;
    notifyListeners();
  }

  // Proceed to payment (mock implementation)
  void proceedToPayment(BuildContext context) {
    // This would typically navigate to a payment processing page
    // For now, we'll just show a dialog confirming the selection
    final VipPlan selected = plans.firstWhere((plan) => plan.id == _selectedPlanId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Selected'),
        content: Text(
          'You\'ve selected the ${selected.name} plan for \$${selected.price.toStringAsFixed(2)}. '
          'In a real app, this would proceed to payment processing.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
