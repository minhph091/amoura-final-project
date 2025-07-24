import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileAvatarCover extends StatefulWidget {
  final String? avatarUrl;
  final String? coverUrl;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;
  final VoidCallback? onViewCover;
  final VoidCallback? onViewAvatar;

  const ProfileAvatarCover({
    super.key,
    this.avatarUrl,
    this.coverUrl,
    this.onEditAvatar,
    this.onEditCover,
    this.onViewCover,
    this.onViewAvatar,
  });

  @override
  State<ProfileAvatarCover> createState() => _ProfileAvatarCoverState();
}

class _ProfileAvatarCoverState extends State<ProfileAvatarCover> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover photo without padding, allowing full view when scrolled
        if (widget.coverUrl != null)
          SizedBox(
            height: 260, // Initial visible height
            width: double.infinity,
            child: GestureDetector(
              onTap: widget.onViewCover,
              child: Image.network(
                widget.coverUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter, // Show top part initially
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: ProfileTheme.darkPurple.withValues(alpha: 0.1),
                  child: Center(child: Icon(Icons.image, size: 50, color: ProfileTheme.darkPurple)),
                ),
              ),
            ),
          ),

        // Edit cover button
        if (widget.onEditCover != null)
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              child: IconButton(
                icon: Icon(Icons.edit, color: ProfileTheme.darkPink),
                onPressed: widget.onEditCover,
              ),
            ),
          ),

        // Avatar positioned over the cover
        Positioned(
          bottom: -30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: widget.onViewAvatar,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: widget.avatarUrl != null ? NetworkImage(widget.avatarUrl!) : null,
                    backgroundColor: ProfileTheme.lightPink.withValues(alpha: 0.2),
                    child: widget.avatarUrl == null
                        ? Icon(Icons.person, size: 60, color: ProfileTheme.darkPink)
                        : null,
                  ),
                ),
              ),
              if (widget.onEditAvatar != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.edit, color: ProfileTheme.darkPink, size: 20),
                      onPressed: widget.onEditAvatar,
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
