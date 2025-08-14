// lib/presentation/discovery/widgets/image_carousel.dart
// Carousel of user's cover and profile images

import 'package:flutter/material.dart';
import '../../../data/models/profile/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageCarouselController {
  void Function()? _reset;
  void resetToFirstImage() {
    _reset?.call();
  }
}

class ImageCarousel extends StatefulWidget {
  final List<PhotoModel> photos;
  final bool showStoryProgress;
  final ImageCarouselController? controller;
  final String? uniqueKey;

  const ImageCarousel({
    super.key,
    required this.photos,
    this.showStoryProgress = false,
    this.controller,
    this.uniqueKey,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupController();
    _preloadImages();
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset về ảnh đầu tiên khi profile thay đổi
    if (oldWidget.uniqueKey != widget.uniqueKey) {
      _resetToFirstImage();
      _preloadImages();
    }
  }

  void _setupController() {
    widget.controller?._reset = _resetToFirstImage;
  }

  void _preloadImages() {
    // Preload đơn giản các ảnh tiếp theo
    for (int i = 1; i < widget.photos.length && i <= 3; i++) {
      final photo = widget.photos[i];
      if (photo.displayUrl.isNotEmpty && mounted) {
        try {
          precacheImage(CachedNetworkImageProvider(photo.displayUrl), context);
        } catch (e) {
          print('ImageCarousel: Lỗi preload ${photo.displayUrl} - $e');
        }
      }
    }
  }

  void _resetToFirstImage() {
    if (mounted && _currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.person,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Main carousel
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: widget.photos.length,
          itemBuilder: (context, index) {
            final photo = widget.photos[index];
            return _buildImageWidget(photo.displayUrl);
          },
        ),

        // Story progress bar
        if (widget.showStoryProgress && widget.photos.length > 1)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: List.generate(
                widget.photos.length,
                (index) => Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Left/Right tap areas
        if (widget.photos.length > 1) ...[
          // Left tap area (previous)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.3,
            child: GestureDetector(
              onTap: _previousImage,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Right tap area (next)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: MediaQuery.of(context).size.width * 0.3,
            child: GestureDetector(
              onTap: _nextImage,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.grey,
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextImage() {
    if (_currentIndex < widget.photos.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
