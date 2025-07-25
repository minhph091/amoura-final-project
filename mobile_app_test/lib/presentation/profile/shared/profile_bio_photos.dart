import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
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
        if (galleryPhotos != null && galleryPhotos!.isNotEmpty) ...[
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
          // Replace the horizontal list with a grid view similar to edit profile
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
            padding: EdgeInsets.zero,
            children: galleryPhotos!.asMap().entries.map((entry) {
              final i = entry.key;
              final url = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: onViewPhoto != null ? () => onViewPhoto!(url) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: ProfileTheme.lightPurple),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: ProfileTheme.lightPink.withValues(alpha: 0.2),
                            child: Icon(Icons.image_not_supported, color: ProfileTheme.darkPink),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (editable && onRemovePhoto != null)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: GestureDetector(
                        onTap: () => onRemovePhoto!(i),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Icon(Icons.close, color: Colors.red, size: 18),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
