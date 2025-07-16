import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import '../notification_viewmodel.dart';
import 'notification_item.dart';

class NotificationGroup extends StatelessWidget {
  final String title;
  final List<NotificationModel> notifications;
  final Function(NotificationModel) onNotificationTap;
  final Function(NotificationModel) onNotificationDismiss;
  final VoidCallback? onMarkAllAsRead;
  final VoidCallback? onDeleteAll;

  const NotificationGroup({
    super.key,
    required this.title,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismiss,
    this.onMarkAllAsRead,
    this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.black54,
                ),
              ),
              // Action buttons
              if (notifications.isNotEmpty)
                Row(
                  children: [
                    // Mark all as read button
                    if (onMarkAllAsRead != null &&
                        notifications.any((n) => !n.isRead))
                      GestureDetector(
                        onTap: onMarkAllAsRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('mark_all_read'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Delete all button
                    if (onDeleteAll != null)
                      GestureDetector(
                        onTap: () => _showDeleteAllConfirmation(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).translate('delete_all'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),

        // Group notifications
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Container(
                margin:
                    index == 0
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onLongPress:
                      () => _showDeleteConfirmation(context, notification),
                  child: NotificationItem(
                    notification: notification,
                    onTap: () => onNotificationTap(notification),
                    onDismiss: () => onNotificationDismiss(notification),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    NotificationModel notification,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context).translate('delete_notification'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).translate('delete_notification_message'),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onNotificationDismiss(notification);
              },
              child: Text(
                AppLocalizations.of(context).translate('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            AppLocalizations.of(context).translate('delete_all_notifications'),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(context)
                .translate('delete_all_notifications_message')
                .replaceAll('{count}', notifications.length.toString()),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).translate('cancel'),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteAll?.call();
              },
              child: Text(
                AppLocalizations.of(context).translate('delete_all'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
