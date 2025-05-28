import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'theme/profile_theme.dart';
import 'widgets/expandable_text.dart';

class ProfileBioPhotos extends StatelessWidget {
  final String? bio;
  final List<String>? galleryPhotos;
  final bool editable;
  final VoidCallback? onEditBio;
  final VoidCallback? onAddPhoto;
  final void Function(int idx)? onRemovePhoto;
  final void Function(String url)? onViewPhoto;

  const ProfileBioPhotos({
    super.key,
    this.bio,
    this.galleryPhotos,
    this.editable = false,
    this.onEditBio,
    this.onAddPhoto,
    this.onRemovePhoto,
    this.onViewPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bio != null && bio!.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.edit_note, color: ProfileTheme.darkPink),
              const SizedBox(width: 8),
              Text('Bio', style: ProfileTheme.getSubtitleStyle(context)),
              if (editable && onEditBio != null)
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: ProfileTheme.darkPink),
                  onPressed: onEditBio,
                  tooltip: "Edit Bio",
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: ExpandableText(text: bio!, maxLines: 2),
          ),
          const SizedBox(height: 18),
        ],
        if (galleryPhotos != null) ...[
          Row(
            children: [
              Icon(Icons.photo_library, color: ProfileTheme.darkPink),
              const SizedBox(width: 8),
              Text('Gallery Photos', style: ProfileTheme.getSubtitleStyle(context)),
              if (editable && onAddPhoto != null)
                IconButton(
                  icon: Icon(Icons.add_a_photo, color: ProfileTheme.darkPink),
                  onPressed: onAddPhoto,
                  tooltip: "Add Photo",
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: galleryPhotos!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final url = galleryPhotos![i];
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: onViewPhoto != null ? () => onViewPhoto!(url) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ProfileTheme.darkPurple.withOpacity(0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            url,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: ProfileTheme.lightPink.withOpacity(0.2),
                              child: Icon(Icons.image_not_supported, color: ProfileTheme.darkPink),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (editable && onRemovePhoto != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto!(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: Icon(Icons.close, color: ProfileTheme.darkPink, size: 16),
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