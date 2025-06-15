import 'package:flutter/foundation.dart';
import '../../../domain/models/subscription/subscription_plan.dart';
import '../../../infrastructure/services/subscription_service.dart';

class PlanListViewModel with ChangeNotifier {
  final SubscriptionService _subscriptionService;
  SubscriptionPlan? _selectedPlan;
  bool _isLoading = false;
  String? _errorMessage;

  PlanListViewModel(this._subscriptionService);

  // Getters
  List<SubscriptionPlan> get availablePlans => _subscriptionService.availablePlans;
  SubscriptionPlan? get selectedPlan => _selectedPlan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isVip => _subscriptionService.isVip;

  // Find the most popular or recommended plan
  SubscriptionPlan get recommendedPlan =>
      availablePlans.firstWhere((plan) => plan.isPopular,
          orElse: () => availablePlans[1]); // Default to middle plan if none is marked popular

  void selectPlan(SubscriptionPlan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  Future<bool> purchaseSelectedPlan() async {
    if (_selectedPlan == null) {
      _errorMessage = "Please select a subscription plan first";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.purchaseSubscription(_selectedPlan!);
      _isLoading = false;
      if (!result) {
        _errorMessage = "Failed to process payment. Please try again.";
      }
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An error occurred: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
