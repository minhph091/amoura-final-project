// filepath: c:\amoura-final-project\mobile-app\lib\presentation\subscription\subscription_plans_view.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/language/app_localizations.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'widgets/subscription_card.dart';
import 'widgets/vip_benefit_item.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView> {
  final PageController _pageController = PageController(
    initialPage: 1,
    viewportFraction: 0.8,
  );
  int _currentPage = 1;

  final List<Map<String, dynamic>> _subscriptionPlans = [
    {
      'duration': '1 MONTH',
      'price': '9.99',
      'totalPrice': '9.99',
      'discount': '0%',
      'color': const Color(0xFF9C27B0),
    },
    {
      'duration': '6 MONTHS',
      'price': '6.99',
      'totalPrice': '41.94',
      'discount': '30%',
      'color': const Color(0xFF3F51B5),
      'isPopular': true,
    },
    {
      'duration': '12 MONTHS',
      'price': '5.99',
      'totalPrice': '71.88',
      'discount': '40%',
      'color': const Color(0xFF2196F3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _pageController.animateToPage(
          (_currentPage + 1) % _subscriptionPlans.length,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Amoura VIP',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.translate('unlock_premium_features'),
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  localizations.translate('premium_benefits_subtitle'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // VIP Benefits
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    VIPBenefitItem(
                      icon: Icons.refresh,
                      text: localizations.translate('unlimited_left_swipes'),
                    ),
                    const SizedBox(height: 12),
                    VIPBenefitItem(
                      icon: Icons.history,
                      text: localizations.translate('go_back_profiles'),
                    ),
                    const SizedBox(height: 12),
                    VIPBenefitItem(
                      icon: Icons.favorite,
                      text: localizations.translate('see_who_liked'),
                    ),
                    const SizedBox(height: 12),
                    VIPBenefitItem(
                      icon: Icons.star,
                      text: localizations.translate('featured_profile'),
                    ),
                    const SizedBox(height: 12),
                    const VIPBenefitItem(
                      icon: Icons.card_giftcard,
                      text: 'Exclusive gifts and privileges',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Subscription Plans Carousel
              SizedBox(
                height: 220,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _subscriptionPlans.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final plan = _subscriptionPlans[index];
                    final isSelected = _currentPage == index;

                    return SubscriptionCard(
                      duration: plan['duration'],
                      price: plan['price'],
                      totalPrice: plan['totalPrice'],
                      discount: plan['discount'],
                      color: plan['color'],
                      isPopular: plan['isPopular'] ?? false,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _subscriptionPlans.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withValues(
                                alpha: 0.3,
                              ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Payment Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to payment page
                    // For now, just show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          localizations.translate('payment_coming_soon'),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'PROCEED TO PAYMENT',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
