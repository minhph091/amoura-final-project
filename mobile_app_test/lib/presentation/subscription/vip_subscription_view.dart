import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'vip_subscription_viewmodel.dart';
import 'widgets/vip_benefit_card.dart';
import 'widgets/vip_plan_carousel.dart';
import '../../config/language/app_localizations.dart';

class VipSubscriptionView extends StatelessWidget {
  const VipSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
                title: Text(
                  localizations.translate('amoura_vip'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                              color: const Color(0xFFE94057).withValues(
                                alpha: 0.5,
                                red: 0.91,
                                green: 0.25,
                                blue: 0.34,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            localizations.translate('vip'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        localizations.translate('unlock_premium_features'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        localizations.translate('get_premium_benefits'),
                        style: TextStyle(
                          color: Colors.white.withValues(
                            alpha: 0.9,
                            red: 1,
                            green: 1,
                            blue: 1,
                          ),
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

                      Row(
                        children: [
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.replay,
                              title: AppLocalizations.of(
                                context,
                              ).translate('unlimited_rewind'),
                              description: AppLocalizations.of(
                                context,
                              ).translate('rewind_description'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.visibility,
                              title: AppLocalizations.of(
                                context,
                              ).translate('see_who_liked_you'),
                              description: AppLocalizations.of(
                                context,
                              ).translate('see_who_liked_description'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.verified,
                              title: AppLocalizations.of(
                                context,
                              ).translate('featured_profile'),
                              description: AppLocalizations.of(
                                context,
                              ).translate('featured_profile_description'),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: VipBenefitCard(
                              icon: Icons.card_giftcard,
                              title: AppLocalizations.of(
                                context,
                              ).translate('special_gifts'),
                              description: AppLocalizations.of(
                                context,
                              ).translate('special_gifts_description'),
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
                            shadowColor: const Color(0xFFE94057).withValues(
                              alpha: 0.5,
                              red: 0.91,
                              green: 0.25,
                              blue: 0.34,
                            ),
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
                          color: Colors.white.withValues(
                            alpha: 0.7,
                            red: 1,
                            green: 1,
                            blue: 1,
                          ),
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
