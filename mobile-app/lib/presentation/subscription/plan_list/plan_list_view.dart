import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme/app_colors.dart';
import '../../../domain/models/subscription/subscription_plan.dart';
import '../../../infrastructure/services/subscription_service.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/gradient_container.dart';
import 'plan_list_viewmodel.dart';
import 'widgets/subscription_plan_card.dart';
import 'widgets/vip_feature_card.dart';

class PlanListView extends StatefulWidget {
  final bool fromVipPromotion;
  final String? sourceFeature; // Which feature triggered the promotion (e.g., 'rewind', 'likes')

  const PlanListView({
    Key? key,
    this.fromVipPromotion = false,
    this.sourceFeature,
  }) : super(key: key);

  @override
  State<PlanListView> createState() => _PlanListViewState();
}

class _PlanListViewState extends State<PlanListView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final PageController _planPageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // If we have a specific feature that triggered this view, focus on it
    if (widget.sourceFeature != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final viewModel = Provider.of<PlanListViewModel>(context, listen: false);
        // Select appropriate tab based on source feature
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _planPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PlanListViewModel(Provider.of<SubscriptionService>(context, listen: false)),
      child: Consumer<PlanListViewModel>(
        builder: (context, viewModel, _) {
          // Auto-select the recommended plan when the view is first created
          if (viewModel.selectedPlan == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.selectPlan(viewModel.recommendedPlan);
            });
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Amoura VIP'),
              centerTitle: true,
              elevation: 0,
            ),
            body: GradientContainer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // VIP logo and title
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pink.shade300,
                                    Colors.purple.shade300
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Amoura VIP',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unlock premium features',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tabs for Benefits and Plans
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'VIP Benefits'),
                        Tab(text: 'Choose a Plan'),
                      ],
                      labelColor: Theme.of(context).primaryColor,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                      indicatorColor: Theme.of(context).primaryColor,
                    ),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // VIP Benefits Tab
                          _buildBenefitsTab(context, viewModel),

                          // Choose a Plan Tab
                          _buildPlansTab(context, viewModel),
                        ],
                      ),
                    ),

                    // Bottom action button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AppButton(
                        text: _tabController.index == 0
                            ? 'Choose a Plan'
                            : 'Continue to Payment',
                        isLoading: viewModel.isLoading,
                        onPressed: () {
                          if (_tabController.index == 0) {
                            _tabController.animateTo(1);
                          } else {
                            _proceedToPayment(context, viewModel);
                          }
                        },
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitsTab(BuildContext context, PlanListViewModel viewModel) {
    final subscriptionService = Provider.of<SubscriptionService>(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Exclusive VIP Benefits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // List of VIP features
        ...subscriptionService.vipFeatures.map((feature) =>
          VipFeatureCard(
            feature: feature,
            isHighlighted: widget.sourceFeature == feature.id,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansTab(BuildContext context, PlanListViewModel viewModel) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Horizontal scrolling plans
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: PageView.builder(
            controller: _planPageController,
            itemCount: viewModel.availablePlans.length,
            onPageChanged: (index) {
              viewModel.selectPlan(viewModel.availablePlans[index]);
            },
            itemBuilder: (context, index) {
              final plan = viewModel.availablePlans[index];
              final isSelected = viewModel.selectedPlan?.id == plan.id;

              return SubscriptionPlanCard(
                plan: plan,
                isSelected: isSelected,
                onTap: () => viewModel.selectPlan(plan),
                animation: isSelected
                  ? _buildSelectionAnimation(context)
                  : null,
              );
            },
          ),
        ),

        // Plan details
        if (viewModel.selectedPlan != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s included:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...viewModel.selectedPlan!.benefits.map((benefit) =>
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(benefit),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Error message
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              viewModel.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  Animation<double> _buildSelectionAnimation(BuildContext context) {
    return Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: ModalRoute.of(context)!.animation!,
        curve: Curves.easeOut,
      ),
    );
  }

  void _proceedToPayment(BuildContext context, PlanListViewModel viewModel) {
    if (viewModel.selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a subscription plan'),
        ),
      );
      return;
    }

    // Navigate to payment screen
    Navigator.pushNamed(
      context,
      '/subscription/payment',
      arguments: viewModel.selectedPlan,
    );
  }
}
