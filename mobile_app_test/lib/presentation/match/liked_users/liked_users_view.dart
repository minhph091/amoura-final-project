import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/language/app_localizations.dart';
import '../../../infrastructure/services/likes_service.dart';
import '../../../app/core/navigation.dart' as app_navigation;
import 'liked_users_viewmodel.dart';
import 'widgets/liked_user_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../shared/widgets/app_gradient_background.dart';

class LikedUsersView extends StatefulWidget {
  const LikedUsersView({super.key});

  @override
  State<LikedUsersView> createState() => _LikedUsersViewState();
}

class _LikedUsersViewState extends State<LikedUsersView> {
  @override
  void initState() {
    super.initState();
    // Fetch liked users when the view is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final likesService = Provider.of<LikesService>(context, listen: false);
      likesService.fetchLikedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ChangeNotifierProvider(
      create: (_) => LikedUsersViewModel(),
      child: Consumer<LikedUsersViewModel>(
        builder: (context, viewModel, _) {
          // Get likes service
          final likesService = Provider.of<LikesService>(context);

          return AppGradientBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Center(
                  child: Text(localizations.translate('who_liked_you')),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  // Content - hiển thị cho tất cả user, không cần VIP
                  RefreshIndicator(
                    onRefresh: () => likesService.fetchLikedUsers(),
                    child: _buildContent(context, viewModel, likesService),
                  ),

                  // Đã loại bỏ VIP overlay - cho phép tất cả user xem
                  // if (!subscriptionService.isVip)
                  //   _buildVipOverlay(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    LikedUsersViewModel viewModel,
    LikesService likesService,
  ) {
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
              onLike: () => viewModel.likeUser(context, user),
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: (50 * index).ms)
            .slideY(
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
    return const Center(child: CircularProgressIndicator());
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
              final likesService = Provider.of<LikesService>(
                app_navigation.navigatorKey.currentContext!,
                listen: false,
              );
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
          Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
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
}
