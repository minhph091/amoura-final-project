import 'package:flutter/material.dart';
import '../../config/language/app_localizations.dart';
import '../shared/widgets/app_gradient_background.dart';
import 'notification_viewmodel.dart';
import 'widgets/notification_group.dart';
import '../../app/routes/app_routes.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with SingleTickerProviderStateMixin {
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
    final localizations = AppLocalizations.of(context);

    return AppGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(localizations.translate('notifications')),
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.white,
                unselectedLabelColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black54,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: [
                  Tab(
                    text: AppLocalizations.of(
                      context,
                    ).translate('likes_matches'),
                  ),
                  Tab(text: AppLocalizations.of(context).translate('messages')),
                  Tab(
                    text: AppLocalizations.of(
                      context,
                    ).translate('notifications_system'),
                  ),
                ],
              ),
            ),
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
                      AppLocalizations.of(
                        context,
                      ).translate('error_loading_notifications'),
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
                      label: Text(localizations.translate('retry')),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Likes tab
                _buildGroupedNotificationList(
                  _viewModel.getLikeNotifications(),
                  localizations.translate('no_likes_yet'),
                  localizations.translate('no_likes_description'),
                  NotificationType.like,
                ),

                // Messages tab
                _buildGroupedNotificationList(
                  _viewModel.getMessageNotifications(),
                  localizations.translate('no_message_notifications'),
                  localizations.translate(
                    'no_message_notifications_description',
                  ),
                  NotificationType.message,
                ),

                // System tab
                _buildGroupedNotificationList(
                  _viewModel.getSystemNotifications(),
                  localizations.translate('no_system_notifications'),
                  localizations.translate(
                    'no_system_notifications_description',
                  ),
                  NotificationType.system,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGroupedNotificationList(
    List<NotificationModel> notifications,
    String emptyTitle,
    String emptySubtitle,
    NotificationType type,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(emptyTitle, emptySubtitle);
    }

    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate(
      notifications,
      context,
    );

    return RefreshIndicator(
      onRefresh: _viewModel.loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 100),
        itemCount: groupedNotifications.length,
        itemBuilder: (context, index) {
          final entry = groupedNotifications.entries.elementAt(index);
          return NotificationGroup(
            title: entry.key,
            notifications: entry.value,
            onNotificationTap:
                (notification) => _handleNotificationTap(context, notification),
            onNotificationDismiss:
                (notification) =>
                    _viewModel.dismissNotification(notification.id),
            onMarkAllAsRead: () => _viewModel.markAllAsReadInGroup(entry.value),
            onDeleteAll: () => _viewModel.deleteAllInGroup(entry.value),
          );
        },
      ),
    );
  }

  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications,
    BuildContext context,
  ) {
    final localizations = AppLocalizations.of(context);
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();

    for (final notification in notifications) {
      final notificationDate = notification.time;
      String groupKey;

      final difference = now.difference(notificationDate).inDays;

      if (difference == 0) {
        groupKey = localizations.translate('today');
      } else if (difference == 1) {
        groupKey = localizations.translate('yesterday');
      } else if (difference < 7) {
        groupKey = localizations.translate('this_week');
      } else if (difference < 30) {
        groupKey = localizations.translate('last_week');
      } else {
        groupKey = localizations.translate('older');
      }

      grouped.putIfAbsent(groupKey, () => []);
      grouped[groupKey]!.add(notification);
    }

    // Sort each group by time (newest first)
    grouped.forEach((key, value) {
      value.sort((a, b) => b.time.compareTo(a.time));
    });

    return grouped;
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(subtitle, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    final localizations = AppLocalizations.of(context);
    _viewModel.markAsRead(notification.id);
    if (notification.type == NotificationType.match ||
        notification.type == NotificationType.like) {
      // Show dialog với 2 lựa chọn
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
                ListTile(
                  leading: const Icon(Icons.chat),
                  title: Text(localizations.translate('chat')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chatConversation,
                      arguments: {
                        'chatId': notification.userId ?? notification.id,
                        'recipientName': notification.title, // hoặc notification.body nếu phù hợp
                        'recipientAvatar': notification.avatar,
                        'isOnline': false,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(localizations.translate('view_info')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/profile/view',
                      arguments: notification.userId,
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      );
      return;
    }
    // Logic cũ cho message/system
    switch (notification.type) {
      case NotificationType.message:
        Navigator.pushNamed(
          context,
          AppRoutes.chatConversation,
          arguments: {
            'chatId': notification.userId ?? notification.id,
            'recipientName': notification.title, // hoặc notification.body nếu phù hợp
            'recipientAvatar': notification.avatar,
            'isOnline': false,
          },
        );
        break;
      case NotificationType.system:
        if (notification.url != null) {
          // Navigate to a web view or deep link
        }
        break;
      default:
        break;
    }
  }

  void _showNotificationOptions(BuildContext context, NotificationType type) {
    final localizations = AppLocalizations.of(context);
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
                title: Text(localizations.translate('mark_all_as_read')),
                onTap: () {
                  Navigator.pop(context);
                  _viewModel.markAllAsReadByType(type);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'All ${type.name} notifications marked as read',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  localizations.translate('clear_all_notifications'),
                  style: const TextStyle(color: Colors.red),
                ),
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

  void _showClearConfirmationDialog(
    BuildContext context,
    NotificationType type,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)
                  .translate('clear_notifications_title')
                  .replaceAll('{type}', type.name),
            ),
            content: Text(
              'This will remove all ${type.name} notifications. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).translate('cancel').toUpperCase(),
                ),
              ),
              TextButton(
                onPressed: () {
                  _viewModel.clearAllByType(type);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)
                            .translate('all_notifications_cleared')
                            .replaceAll('{type}', type.name),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  AppLocalizations.of(context).translate('clear').toUpperCase(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
