import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String? coverUrl;
  final String? displayName;
  final String? username;
  final bool isVip;
  final bool showEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onActionMenu;
  final double coverHeight;
  final double avatarSize;

  const ProfileHeader({
    super.key,
    this.avatarUrl,
    this.coverUrl,
    this.displayName,
    this.username,
    this.isVip = false,
    this.showEdit = false,
    this.onEdit,
    this.onActionMenu,
    this.coverHeight = 160,
    this.avatarSize = 92,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Cover image (show only top part)
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          child: Container(
            height: coverHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isVip
                  ? null
                  : (isDark ? Colors.grey[900] : Colors.grey[200]),
              gradient: isVip
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFE066),
                  Color(0xFFFFB5E8),
                  Color(0xFFB8FFEC),
                  Color(0xFFF2A8FF),
                ],
              )
                  : null,
              image: coverUrl != null && coverUrl!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(coverUrl!),
                fit: BoxFit.cover,
                colorFilter: isVip
                    ? ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.12),
                  BlendMode.darken,
                )
                    : null,
              )
                  : null,
            ),
            child: (coverUrl == null || coverUrl!.isEmpty)
                ? Center(
              child: Icon(Icons.image, size: 64, color: theme.disabledColor),
            )
                : null,
          ),
        ),
        // VIP overlay
        if (isVip)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x33FFD700),
                      Color(0x22FF69B4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
        // Avatar
        Positioned(
          bottom: -avatarSize / 2 + 10,
          left: MediaQuery.of(context).size.width / 2 - avatarSize / 2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isVip)
                Container(
                  width: avatarSize + 10,
                  height: avatarSize + 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Color(0xFFE91E63),
                        Color(0xFFFFEB3B),
                        Color(0xFFF44336),
                        Color(0xFF9C27B0),
                        Color(0xFFE91E63),
                      ],
                    ),
                  ),
                ),
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: isVip ? Border.all(color: Colors.transparent, width: 3) : null,
                ),
                child: ClipOval(
                  child: avatarUrl == null || avatarUrl!.isEmpty
                      ? Icon(Icons.person, size: avatarSize * 0.7, color: theme.disabledColor)
                      : Image.network(avatarUrl!, fit: BoxFit.cover),
                ),
              ),
              if (isVip)
                Positioned(
                  bottom: 2,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF69B4)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'VIP',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 2)]
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Name, username, edit or menu
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: EdgeInsets.only(top: avatarSize / 2 + 18),
            child: Column(
              children: [
                Text(
                  displayName?.isNotEmpty == true ? displayName! : '-',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isVip
                        ? const Color(0xFFFFD700)
                        : theme.textTheme.bodyLarge?.color,
                    shadows: isVip
                        ? [const Shadow(color: Colors.amberAccent, blurRadius: 8)]
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (username != null && username!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '@$username',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary.withAlpha(180),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (showEdit && onEdit != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profile',
                      onPressed: onEdit,
                    ),
                  ),
                if (!showEdit && onActionMenu != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_rounded),
                      tooltip: 'More',
                      onPressed: onActionMenu,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
