import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../infrastructure/services/likes_service.dart';
import '../../../infrastructure/services/subscription_service.dart';
import '../../../app/core/navigation.dart' as app_navigation;
import 'liked_users_viewmodel.dart';
import 'widgets/liked_user_card.dart';
import '../../subscription/widgets/vip_promotion_dialog.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/app_gradient_background.dart';

class LikedUsersView extends StatelessWidget {
  const LikedUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LikedUsersViewModel(),
      child: Consumer<LikedUsersViewModel>(
        builder: (context, viewModel, _) {
          // Get subscription service to check if user is VIP
          final subscriptionService = Provider.of<SubscriptionService>(context);
          final likesService = Provider.of<LikesService>(context);

          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Center(child: const Text('Who Liked You')),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  if (subscriptionService.isVip)
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // Filter functionality for VIP users
                        viewModel.toggleFilterMenu();
                      },
                    ),
                ],
              ),
              body: Stack(
                children: [
                  // Content - will be blurred if not VIP
                  RefreshIndicator(
                    onRefresh: () => likesService.fetchLikedUsers(),
                    child: _buildContent(context, viewModel, likesService),
                  ),

                  // VIP overlay if not subscribed
                  if (!subscriptionService.isVip)
                    _buildVipOverlay(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, LikedUsersViewModel viewModel, LikesService likesService) {
    if (likesService.isLoading) {
      return _buildLoadingState();
    }

    if (likesService.error != null) {
      return _buildErrorState(likesService.error!);
    }

    if (likesService.likedUsers.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: likesService.likedUsers.length,
      itemBuilder: (context, index) {
        final user = likesService.likedUsers[index];
        return LikedUserCard(
          user: user,
          onTap: () => viewModel.navigateToUserProfile(context, user),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(
              begin: 0.2,
              end: 0,
              duration: 300.ms,
              delay: (50 * index).ms,
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading likes',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final likesService = Provider.of<LikesService>(app_navigation.navigatorKey.currentContext!, listen: false);
              likesService.fetchLikedUsers();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Likes Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Keep swiping and improve your profile to get more likes!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipOverlay(BuildContext context) {
    return VipPromotionDialog(
      featureTitle: 'See Who Likes You',
      featureId: 'see_likes',
      description: 'Upgrade to Amoura VIP to see all the users who have liked your profile!',
      icon: Icons.favorite,
    );
  }
}
