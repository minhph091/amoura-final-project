import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'theme/profile_theme.dart';

class ProfileAvatarCover extends StatelessWidget {
  final String? avatarUrl;
  final String? coverUrl;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;
  final VoidCallback? onViewCover;

  const ProfileAvatarCover({
    super.key,
    this.avatarUrl,
    this.coverUrl,
    this.onEditAvatar,
    this.onEditCover,
    this.onViewCover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (coverUrl != null)
          Stack(
            children: [
              GestureDetector(
                onTap: onViewCover,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    coverUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      color: ProfileTheme.darkPurple.withOpacity(0.1),
                      child: Center(child: Icon(Icons.image, size: 50, color: ProfileTheme.darkPurple)),
                    ),
                  ),
                ),
              ),
              if (onEditCover != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: ProfileTheme.darkPink),
                      onPressed: onEditCover,
                    ),
                  ),
                ),
            ],
          ),
        Transform.translate(
          offset: const Offset(0, -40),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 52,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  backgroundColor: ProfileTheme.lightPink.withOpacity(0.2),
                  child: avatarUrl == null
                      ? Icon(Icons.person, size: 60, color: ProfileTheme.darkPink)
                      : null,
                ),
              ),
              if (onEditAvatar != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.edit, color: ProfileTheme.darkPink, size: 20),
                      onPressed: onEditAvatar,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}