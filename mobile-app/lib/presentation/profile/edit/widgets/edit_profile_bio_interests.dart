// lib/presentation/profile/edit/widgets/edit_profile_bio_interests.dart

import 'package:flutter/material.dart';
import '../../shared/profile_bio_photos.dart';

class EditProfileBioInterests extends StatelessWidget {
  final String? bio;
  final List<String>? interests;
  final VoidCallback? onEditBio;
  final VoidCallback? onEditInterests;

  const EditProfileBioInterests({
    super.key,
    this.bio,
    this.interests,
    this.onEditBio,
    this.onEditInterests,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileBioPhotos(
      bio: bio,
      galleryPhotos: interests, // Reuse as interests if needed, else change to correct widget
      editable: true,
      onEditBio: onEditBio,
      onAddPhoto: null,
      onRemovePhoto: null,
    );
  }
}