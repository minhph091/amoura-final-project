import 'package:flutter/material.dart';
import '../notification_viewmodel.dart';
import '../../shared/utils/time_formatter.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: Colors.red,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        if (onDismiss != null) {
          onDismiss!();
        }
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? null
                : Theme.of(context).colorScheme.primary.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeadingIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          TimeFormatter.formatChatTime(notification.time),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: notification.isRead
                            ? Colors.grey[600]
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        height: 1.3,
                      ),
                    ),
                    // Show unread indicator
                    if (!notification.isRead)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    if (notification.avatar != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(notification.avatar!),
      );
    }

    // Icon based on notification type
    IconData icon;
    Color backgroundColor;

    switch (notification.type) {
      case NotificationType.match:
        icon = Icons.favorite;
        backgroundColor = Colors.red;
        break;
      case NotificationType.message:
        icon = Icons.chat_bubble;
        backgroundColor = Colors.green;
        break;
      case NotificationType.like:
        icon = Icons.favorite_border;
        backgroundColor = Colors.pink;
        break;
      case NotificationType.system:
        icon = Icons.notifications;
        backgroundColor = Colors.blue;
        break;
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: backgroundColor.withOpacity(0.2),
      child: Icon(
        icon,
        color: backgroundColor,
        size: 24,
      ),
    );
  }
}
