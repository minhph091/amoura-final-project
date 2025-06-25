import 'package:flutter/material.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'notification_viewmodel.dart';
import 'widgets/notification_item.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with SingleTickerProviderStateMixin {
  final NotificationViewModel _viewModel = NotificationViewModel();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _viewModel.loadNotifications();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _viewModel.setCurrentTabIndex(_tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Notifications'),
          centerTitle: true,
          actions: [
            // Moving the three-dots menu to the app bar
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options based on current tab
                NotificationType currentType;
                switch (_tabController.index) {
                  case 0:
                    currentType = NotificationType.like;
                    break;
                  case 1:
                    currentType = NotificationType.message;
                    break;
                  default:
                    currentType = NotificationType.system;
                }
                _showNotificationOptions(context, currentType);
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
            tabs: const [
              Tab(text: 'Likes'),
              Tab(text: 'Messages'),
              Tab(text: 'System'),
            ],
          ),
        ),
        body: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, _) {
            if (_viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_viewModel.error != null) {
              return Center(
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
                      'Error loading notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _viewModel.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _viewModel.loadNotifications,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Likes tab
                _buildNotificationList(
                  _viewModel.getLikeNotifications(),
                  'No likes yet',
                  'When someone likes your profile, you\'ll see it here.',
                  NotificationType.like,
                ),

                // Messages tab
                _buildNotificationList(
                  _viewModel.getMessageNotifications(),
                  'No message notifications',
                  'When you receive new messages, you\'ll see notifications here.',
                  NotificationType.message,
                ),

                // System tab
                _buildNotificationList(
                  _viewModel.getSystemNotifications(),
                  'No system notifications',
                  'Important updates and announcements will appear here.',
                  NotificationType.system,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationModel> notifications,
    String emptyTitle,
    String emptySubtitle,
    NotificationType type
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }

    return RefreshIndicator(
      onRefresh: _viewModel.loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];

          return NotificationItem(
            notification: notification,
            onTap: () => _handleNotificationTap(context, notification),
            onDismiss: () => _viewModel.dismissNotification(notification.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Mark as read
    _viewModel.markAsRead(notification.id);

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.match:
      case NotificationType.like:
        Navigator.pushNamed(context, '/profile/view', arguments: notification.userId);
        break;
      case NotificationType.message:
        Navigator.pushNamed(context, '/chat/conversation', arguments: notification.userId);
        break;
      case NotificationType.system:
        // System notifications might not have a destination
        if (notification.url != null) {
          // Navigate to a web view or deep link
        }
        break;
    }
  }

  void _showNotificationOptions(BuildContext context, NotificationType type) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.mark_email_read),
                title: const Text('Mark all as read'),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.markAllAsReadByType(type);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('All ${type.name} notifications marked as read'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Clear all notifications', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showClearConfirmationDialog(context, type);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showClearConfirmationDialog(BuildContext context, NotificationType type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear ${type.name} notifications?'),
        content: Text('This will remove all ${type.name} notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              _viewModel.clearAllByType(type);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All ${type.name} notifications cleared'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
