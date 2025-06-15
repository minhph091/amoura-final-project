import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import '../vip_subscription_viewmodel.dart';

class VipPlanCarousel extends StatefulWidget {
  final Function(String) onPlanSelected;
  final String selectedPlanId;

  const VipPlanCarousel({
    super.key,
    required this.onPlanSelected,
    required this.selectedPlanId,
  });

  @override
  State<VipPlanCarousel> createState() => _VipPlanCarouselState();
}

class _VipPlanCarouselState extends State<VipPlanCarousel> {
  final carousel_slider.CarouselController _carouselController = carousel_slider.CarouselController();
  List<VipPlan> _plans = [];
  int _currentIndex = 1; // Default to middle plan (6 months)

  @override
  void initState() {
    super.initState();
    // Initialize with the plans directly
    _loadPlans();
  }

  void _loadPlans() {
    // Hardcoded plans since we can't access the viewModel directly
    _plans = [
      VipPlan(
        id: 'monthly',
        name: '1 Month',
        price: 99000,
        perMonth: 99000,
        savePercent: 0,
        description: 'Renews monthly, cancel anytime',
        features: ['Full Amoura VIP benefits', 'Basic priority in discovery'],
      ),
      VipPlan(
        id: 'biannual',
        name: '6 Months',
        price: 399000,
        perMonth: 66500,
        savePercent: 33,
        description: '6-month plan with special discount',
        features: [
          'Full Amoura VIP benefits',
          'Medium priority in discovery',
          'Seasonal gifts',
        ],
        isPopular: true,
      ),
      VipPlan(
        id: 'annual',
        name: '12 Months',
        price: 599000,
        perMonth: 49900,
        savePercent: 50,
        description: 'Annual plan with the best value',
        features: [
          'Full Amoura VIP benefits',
          'Highest priority in discovery',
          'Seasonal gifts',
          'Exclusive badge on profile',
        ],
      ),
    ];

    // Set current index based on selected plan ID
    _currentIndex = _plans.indexWhere((plan) => plan.id == widget.selectedPlanId);
    if (_currentIndex < 0) _currentIndex = 1; // Default to middle plan
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        carousel_slider.CarouselSlider(
          carouselController: _carouselController,
          options: carousel_slider.CarouselOptions(
            aspectRatio: 16/9,
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            initialPage: _currentIndex,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPlanSelected(_plans[index].id);
            },
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            pauseAutoPlayOnTouch: true,
          ),
          items: _plans.map((plan) {
            final bool isSelected = plan.id == widget.selectedPlanId;
            return _buildPlanCard(plan, isSelected);
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Plan dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _plans.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? const Color(0xFFF06292)
                      : Colors.white.withValues(alpha: 0.4, red: 1, green: 1, blue: 1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPlanCard(VipPlan plan, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isSelected
            ? const LinearGradient(
          colors: [Color(0xFFAD1457), Color(0xFFF06292)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Color(0xFF333333), Color(0xFF555555)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFFD81B60).withValues(alpha: 0.5, red: 0.85, green: 0.11, blue: 0.38)
                : Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Popular badge if applicable
            if (plan.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'MOST POPULAR',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Plan content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Plan name
                  Text(
                    plan.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Plan price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPrice(plan.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'đ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Per month price
                  Text(
                    '${_formatPrice(plan.perMonth)}đ/month',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8, red: 1, green: 1, blue: 1),
                      fontSize: 16,
                    ),
                  ),

                  if (plan.savePercent > 0) ...[
                    const SizedBox(height: 8),
                    // Save percentage
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2, red: 1, green: 1, blue: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Save ${plan.savePercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Plan description
                  Text(
                    plan.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8, red: 1, green: 1, blue: 1),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
    );
  }
}