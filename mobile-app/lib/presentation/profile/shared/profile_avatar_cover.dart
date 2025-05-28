// lib/presentation/profile/shared/profile_avatar_cover.dart

import 'package:flutter/material.dart';

class ProfileAvatarCover extends StatelessWidget {
  final String? avatarUrl;
  final String? coverUrl;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;

  const ProfileAvatarCover({
    super.key,
    this.avatarUrl,
    this.coverUrl,
    this.onEditAvatar,
    this.onEditCover,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (coverUrl != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  coverUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image, size: 40)),
                  ),
                ),
              ),
              if (onEditCover != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                    onPressed: onEditCover,
                  ),
                ),
            ],
          ),
        const SizedBox(height: 8),
        Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
            ),
            if (onEditAvatar != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.surface,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                    onPressed: onEditAvatar,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}