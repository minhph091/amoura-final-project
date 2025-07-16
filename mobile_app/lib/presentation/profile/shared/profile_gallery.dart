import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileGallery extends StatefulWidget {
  final List<String>? galleryPhotos;
  final bool editable;
  final VoidCallback? onAddPhoto;
  final void Function(int idx)? onRemovePhoto;
  final void Function(String url)? onViewPhoto;

  const ProfileGallery({
    super.key,
    this.galleryPhotos,
    this.editable = false,
    this.onAddPhoto,
    this.onRemovePhoto,
    this.onViewPhoto,
  });

  @override
  State<ProfileGallery> createState() => _ProfileGalleryState();
}

class _ProfileGalleryState extends State<ProfileGallery> {
  bool _showAllPhotos = false;

  @override
  Widget build(BuildContext context) {
    if (widget.galleryPhotos == null || widget.galleryPhotos!.isEmpty) {
      return const SizedBox.shrink();
    }

    final hasMoreThanTwoPhotos = widget.galleryPhotos!.length > 2;
    final displayedPhotos =
        _showAllPhotos
            ? widget.galleryPhotos!
            : widget.galleryPhotos!.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Albums', style: ProfileTheme.getSubtitleStyle(context)),
            Row(
              children: [
                if (widget.editable && widget.onAddPhoto != null)
                  IconButton(
                    icon: Icon(
                      Icons.add_a_photo,
                      color: ProfileTheme.darkPink,
                      size: 20,
                    ),
                    onPressed: widget.onAddPhoto,
                    tooltip: "Add Photo",
                  ),
                if (hasMoreThanTwoPhotos)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllPhotos = !_showAllPhotos;
                      });
                    },
                    child: Text(
                      _showAllPhotos ? 'Show Less' : 'View All',
                      style: TextStyle(
                        color: ProfileTheme.darkPink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1,
          padding: EdgeInsets.zero,
          children:
              displayedPhotos.asMap().entries.map((entry) {
                final url = entry.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap:
                          widget.onViewPhoto != null
                              ? () => widget.onViewPhoto!(url)
                              : null,
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
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: ProfileTheme.lightPink.withValues(
                                    alpha: 0.2,
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: ProfileTheme.darkPink,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.editable && widget.onRemovePhoto != null)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap:
                              () => widget.onRemovePhoto!(
                                widget.galleryPhotos!.indexOf(url),
                              ),
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
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }
}
