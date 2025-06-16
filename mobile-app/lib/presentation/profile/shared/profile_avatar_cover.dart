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
  // Control the scroll position of the cover photo
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.coverUrl != null)
          Stack(
            children: [
              // Container to clip the scrollable cover and maintain a fixed height
              SizedBox(
                height: 180,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: widget.onViewCover,
                    // Make the image scrollable
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Image.network(
                        widget.coverUrl!,
                        width: double.infinity,
                        // Using a taller height to allow scrolling
                        height: 300,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: ProfileTheme.darkPurple.withValues(alpha: 0.1),
                          child: Center(child: Icon(Icons.image, size: 50, color: ProfileTheme.darkPurple)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
            ],
          ),
        Transform.translate(
          offset: const Offset(0, -40),
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