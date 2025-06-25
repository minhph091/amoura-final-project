import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'vip_subscription_viewmodel.dart';
import 'widgets/vip_benefit_card.dart';
import 'widgets/vip_plan_carousel.dart';

class VipSubscriptionView extends StatelessWidget {
  const VipSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VipSubscriptionViewModel(),
      child: Consumer<VipSubscriptionViewModel>(
        builder: (context, viewModel, _) {
          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Amoura VIP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // VIP Icon & Title
                      const SizedBox(height: 24),
                      Container(
                        width: 100,
                        height: 100,
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
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "VIP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Upgrade Your Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Become a VIP member to enjoy all the exclusive features of Amoura',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9, red: 1, green: 1, blue: 1),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Benefits section
                      const Text(
                        'VIP Member Privileges',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      const Row(
                        children: [
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.replay,
                              title: 'Unlimited Rewind',
                              description: 'Rewind to any profile you skipped anytime',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.visibility,
                              title: 'See Who Liked You',
                              description: 'View the list of people who liked you',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Row(
                        children: [
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.verified,
                              title: 'Featured Profile',
                              description: 'Your profile will be prioritized for others',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.card_giftcard,
                              title: 'Special Gifts',
                              description: 'Receive gifts during special events',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Plans carousel
                      const Text(
                        'Choose a Plan That Suits You',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      VipPlanCarousel(
                        selectedPlanId: viewModel.selectedPlanId,
                        onPlanSelected: viewModel.selectPlan,
                      ),

                      const SizedBox(height: 32),

                      // Subscribe button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => viewModel.proceedToPayment(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE94057),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFFE94057).withValues(alpha: 0.5, red: 0.91, green: 0.25, blue: 0.34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Proceed to VIP Payment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Subscription renews automatically. You can cancel anytime.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7, red: 1, green: 1, blue: 1),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}