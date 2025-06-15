import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/match/liked_user_model.dart';
import '../../../infrastructure/services/subscription_service.dart';
import '../../shared/widgets/vip_badge.dart';
import 'profile_details_viewmodel.dart';
import 'widgets/profile_action_menu.dart';
import 'widgets/profile_bio_section.dart';
import 'widgets/profile_tab_content.dart';

class ProfileDetailsView extends StatefulWidget {
  final String userId;
  final LikedUserModel? user;

  const ProfileDetailsView({
    Key? key,
    required this.userId,
    this.user,
  }) : super(key: key);

  @override
  State<ProfileDetailsView> createState() => _ProfileDetailsViewState();
}

class _ProfileDetailsViewState extends State<ProfileDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileDetailsViewModel(widget.userId, initialData: widget.user),
      child: Consumer<ProfileDetailsViewModel>(
        builder: (context, viewModel, _) {
          final user = viewModel.user;

          if (viewModel.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.error != null || user == null) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.error ?? 'User not found',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: viewModel.loadProfile,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // App bar with profile cover and avatar
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, color: Colors.white),
                      ),
                      onPressed: () => _showActionMenu(context, viewModel),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _buildCoverAndAvatar(context, user),
                  ),
                ),

                // Profile main information
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name, age, location, username
                        _buildUserHeader(context, user),

                        const SizedBox(height: 16),

                        // Bio with expandable text
                        ProfileBioSection(bio: user.bio),

                        const SizedBox(height: 24),

                        // Tabs for "About" and "Photos"
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'About'),
                            Tab(text: 'Photos'),
                          ],
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                        ),

                        // Tab content
                        SizedBox(
                          height: 400, // Fixed height for tab content
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // About tab
                              ProfileTabContent(
                                type: ProfileTabType.about,
                                user: user,
                              ),

                              // Photos tab
                              ProfileTabContent(
                                type: ProfileTabType.photos,
                                user: user,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Message button at bottom
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => _navigateToChat(context, user),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoverAndAvatar(BuildContext context, LikedUserModel user) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover photo
        Image.network(
          user.coverImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 64,
              color: Colors.white,
            ),
          ),
        ),

        // Gradient overlay for better text visibility
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.5),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
        ),

        // Avatar
        Positioned(
          bottom: 20,
          left: 20,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 47,
              backgroundImage: NetworkImage(user.avatarUrl),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ),

        // VIP badge if applicable
        if (user.isVip)
          Positioned(
            bottom: 15,
            left: 90,
            child: const VipBadge(size: 1.2),
          ),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, LikedUserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and age
        Row(
          children: [
            Expanded(
              child: Text(
                '${user.fullName}, ${user.age}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Username
        Text(
          '@${user.username}',
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(height: 8),

        // Location
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              user.location,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showActionMenu(BuildContext context, ProfileDetailsViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ProfileActionMenu(
        isBlocked: viewModel.isBlocked,
        onReport: () {
          Navigator.of(context).pop();
          _navigateToReportForm(context, viewModel);
        },
        onBlock: () {
          Navigator.of(context).pop();
          _showBlockDialog(context, viewModel);
        },
        onUnblock: () {
          Navigator.of(context).pop();
          _showUnblockDialog(context, viewModel);
        },
      ),
    );
  }

  void _navigateToReportForm(BuildContext context, ProfileDetailsViewModel viewModel) {
    Navigator.of(context).pushNamed(
      '/profile/report',
      arguments: viewModel.userId,
    );
  }

  void _showBlockDialog(BuildContext context, ProfileDetailsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this user?'),
        content: const Text('You won\'t see this user again, and they won\'t be able to contact you.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.blockUser();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User blocked successfully'),
                ),
              );
            },
            child: const Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, ProfileDetailsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock this user?'),
        content: const Text('They will be able to see your profile and contact you again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.unblockUser();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User unblocked successfully'),
                ),
              );
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, LikedUserModel user) {
    Navigator.of(context).pushNamed(
      '/chat/conversation',
      arguments: user.id,
    );
  }
}
