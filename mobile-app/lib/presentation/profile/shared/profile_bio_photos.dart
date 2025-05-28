// lib/presentation/profile/shared/profile_bio_photos.dart

import 'package:flutter/material.dart';

class ProfileBioPhotos extends StatelessWidget {
  final String? bio;
  final List<String>? galleryPhotos;
  final bool editable;
  final VoidCallback? onEditBio;
  final VoidCallback? onAddPhoto;
  final void Function(int idx)? onRemovePhoto;

  const ProfileBioPhotos({
    super.key,
    this.bio,
    this.galleryPhotos,
    this.editable = false,
    this.onEditBio,
    this.onAddPhoto,
    this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bio != null && bio!.isNotEmpty) ...[
          Row(
            children: [
              Text('Bio', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              if (editable && onEditBio != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEditBio,
                  tooltip: "Edit Bio",
                ),
            ],
          ),
          Text(bio!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
        ],
        if (galleryPhotos != null) ...[
          Row(
            children: [
              Text('Gallery Photos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              if (editable && onAddPhoto != null)
                IconButton(
                  icon: const Icon(Icons.add_a_photo),
                  onPressed: onAddPhoto,
                  tooltip: "Add Photo",
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryPhotos!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final url = galleryPhotos![i];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover),
                    ),
                    if (editable && onRemovePhoto != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto!(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, color: Colors.red, size: 16),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}