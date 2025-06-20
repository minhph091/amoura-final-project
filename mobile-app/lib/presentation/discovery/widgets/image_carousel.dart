// lib/presentation/discovery/widgets/image_carousel.dart
// Carousel of user's cover and profile images

import 'package:flutter/material.dart';
import '../../../data/models/profile/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/url_transformer.dart';

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

  const ImageCarousel({
    super.key,
    required this.photos,
    this.showStoryProgress = false,
    this.controller,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget.controller?._reset = _resetToFirstImage;
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.photos != oldWidget.photos) {
      _resetToFirstImage();
    }
    widget.controller?._reset = _resetToFirstImage;
  }

  void _resetToFirstImage() {
    setState(() {
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    final dx = details.localPosition.dx;
    final width = constraints.maxWidth;
    if (dx < width / 2) {
      // Tap left: previous
      if (_currentIndex > 0) {
        setState(() {
          _currentIndex--;
        });
        _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      }
    } else {
      // Tap right: next
      if (_currentIndex < widget.photos.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 90, color: Color(0xFFB5B6B7)),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => _onTapDown(details, constraints),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              physics: const NeverScrollableScrollPhysics(), // Only allow tap navigation
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                final transformedUrl = UrlTransformer.transform(photo.url);
                return CachedNetworkImage(
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
                );
              },
            ),
          ),
          if (widget.showStoryProgress)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: List.generate(widget.photos.length, (i) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _currentIndex ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}