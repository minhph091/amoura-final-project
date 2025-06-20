// lib/presentation/discovery/widgets/image_carousel.dart
// Carousel of user's cover and profile images

import 'package:flutter/material.dart';
import '../../../data/models/profile/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/url_transformer.dart';

class ImageCarousel extends StatelessWidget {
  final List<PhotoModel> photos;

  const ImageCarousel({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFFEFEFFF), Color(0xFFB6D0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 26,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: _buildImageContent(),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.03),
                    Colors.white.withValues(alpha: 0.16),
                    Colors.white.withValues(alpha: 0.44),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (photos.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 90, color: Color(0xFFB5B6B7)),
      );
    }

    return PageView.builder(
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final transformedUrl = UrlTransformer.transform(photo.url);
        return ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: CachedNetworkImage(
            imageUrl: transformedUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.error, size: 50, color: Colors.grey),
              ),
            ),
          ),
        );
      },
    );
  }
}