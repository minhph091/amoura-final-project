// lib/presentation/shared/widgets/photo_viewer.dart

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'network_image.dart';

class PhotoViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;
  final String? description;

  const PhotoViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
                Navigator.of(context).maybePop();
              }
            },
            child: Center(
              child: heroTag != null
                  ? Hero(
                tag: heroTag!,
                child: _buildPhotoView(context),
              )
                  : _buildPhotoView(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: 'Close',
            ),
          ),
          if (description != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoView(BuildContext context) {
    return PhotoView(
      imageProvider: NetworkImage(imageUrl),
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2.5,
      loadingBuilder: (context, event) => NetworkImageWidget(
        imageUrl: imageUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.contain,
      ),
      errorBuilder: (context, error, stackTrace) => NetworkImageWidget(
        imageUrl: imageUrl,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}