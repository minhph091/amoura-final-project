// lib/presentation/profile/view/widgets/profile_cover_avatar.dart

import 'package:flutter/material.dart';
import '../../shared/profile_avatar_cover.dart';

class ProfileCoverAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? coverUrl;
  const ProfileCoverAvatar({super.key, this.avatarUrl, this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 165,
          child: ProfileAvatarCover(
            avatarUrl: avatarUrl,
            coverUrl: coverUrl,
          ),
        ),
        Positioned(
          bottom: 12,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null ? const Icon(Icons.person, size: 48) : null,
            ),
          ),
        ),
      ],
    );
  }
}