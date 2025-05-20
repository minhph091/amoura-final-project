// lib/presentation/shared/widgets/user_avatar.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// A widget that displays a user's avatar with an optional online/offline indicator.
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final bool isOnline;
  final Color? onlineColor;
  final Color? offlineColor;
  final TextStyle? initialsStyle;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 56,
    this.borderWidth = 2.5,
    this.borderColor,
    this.isOnline = false,
    this.onlineColor,
    this.offlineColor,
    this.initialsStyle,
  });

  String getInitials() {
    if (name == null || name!.isEmpty) return '';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderClr = borderColor ?? theme.colorScheme.primary.withOpacity(0.7);
    final onlineClr = onlineColor ?? Colors.greenAccent;
    final offlineClr = offlineColor ?? Colors.grey;
    final initials = getInitials();

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: borderClr,
              width: borderWidth,
            ),
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Shimmer.fromColors(
                  baseColor: theme.colorScheme.surfaceVariant,
                  highlightColor: theme.colorScheme.surface,
                  child: Container(
                    width: size,
                    height: size,
                    color: theme.colorScheme.surfaceVariant,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => _buildInitials(theme, initials),
            )
                : _buildInitials(theme, initials),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: size * 0.22,
            height: size * 0.22,
            decoration: BoxDecoration(
              color: isOnline ? onlineClr : offlineClr,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.scaffoldBackgroundColor,
                width: size * 0.07,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitials(ThemeData theme, String initials) {
    return Container(
      color: theme.colorScheme.surfaceVariant,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: initialsStyle ??
            TextStyle(
              fontSize: size * 0.42,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}