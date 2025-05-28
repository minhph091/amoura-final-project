// lib/presentation/profile/edit/widgets/edit_profile_cover_avatar.dart

import 'package:flutter/material.dart';
import '../../shared/profile_avatar_cover.dart';

class EditProfileCoverAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? coverUrl;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;

  const EditProfileCoverAvatar({
    super.key,
    this.avatarUrl,
    this.coverUrl,
    this.onEditAvatar,
    this.onEditCover,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileAvatarCover(
      avatarUrl: avatarUrl,
      coverUrl: coverUrl,
      onEditAvatar: onEditAvatar,
      onEditCover: onEditCover,
    );
  }
}