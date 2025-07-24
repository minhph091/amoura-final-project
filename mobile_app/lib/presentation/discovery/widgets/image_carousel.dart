// lib/presentation/discovery/widgets/image_carousel.dart
// Carousel of user's cover and profile images

import 'package:flutter/material.dart';
import '../../../data/models/profile/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart'; // Thêm nếu dùng cacheManager tùy chỉnh

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
  final BaseCacheManager? cacheManager; // Thêm tuỳ chọn cacheManager

  const ImageCarousel({
    super.key,
    required this.photos,
    this.showStoryProgress = false,
    this.controller,
    this.uniqueKey,
    this.cacheManager, // Thêm cacheManager
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
    // Chỉ reset khi uniqueKey thực sự thay đổi (profile mới)
    if (widget.uniqueKey != oldWidget.uniqueKey) {
      _resetToFirstImage();
    }
    widget.controller?._reset = _resetToFirstImage;
  }

  void _resetToFirstImage() {
    setState(() {
      _currentIndex = 0;
    });
    
    // Kiểm tra xem PageController đã được attach chưa trước khi gọi jumpToPage
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    } else {
      // Nếu chưa attach, sử dụng Future.delayed để đợi widget được build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
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

  Widget _buildImage(int index) {
    final photo = widget.photos[index];
    return FutureBuilder(
      future: precacheImage(CachedNetworkImageProvider(photo.url), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CachedNetworkImage(
            key: ValueKey('carousel_image_${widget.uniqueKey}_$index'),
            imageUrl: photo.url,
            cacheManager: widget.cacheManager,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            errorWidget: (context, url, error) {
              return const Icon(Icons.broken_image, size: 48, color: Colors.grey);
            },
          );
        }
        return Container(color: Colors.grey[200]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.photos.isEmpty) {
      return const Center(
        child: Icon(Icons.image, size: 90, color: Color(0xFFB5B6B7)),
      );
    }
    return LayoutBuilder(
      builder:
          (context, constraints) => Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _onTapDown(details, constraints),
                child: PageView.builder(
                  key: ValueKey('carousel_${widget.uniqueKey}'),
                  controller: _pageController,
                  itemCount: widget.photos.length,
                  physics:
                      const NeverScrollableScrollPhysics(), // Only allow tap navigation
                  itemBuilder: (context, index) {
                    return _buildImage(index);
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: List.generate(widget.photos.length, (i) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              height: 4,
                              decoration: BoxDecoration(
                                color:
                                    i <= _currentIndex
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.3),
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
