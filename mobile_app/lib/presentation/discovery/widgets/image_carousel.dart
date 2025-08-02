// lib/presentation/discovery/widgets/image_carousel.dart
// Carousel of user's cover and profile images

import 'package:flutter/material.dart';
import '../../../data/models/profile/photo_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../infrastructure/services/cache_cleanup_service.dart';

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
  PageController? _pageController;
  int _currentIndex = 0;
  bool _isDisposed = false;
  String? _lastUniqueKey;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _lastUniqueKey = widget.uniqueKey;
    widget.controller?._reset = resetToFirstImage;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pageController?.dispose();
    super.dispose();
  }

  void _initializeController() {
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detect profile change
    bool isNewProfile = widget.uniqueKey != _lastUniqueKey;
    
    if (isNewProfile) {
      print('[IMAGE_DEBUG] Profile change detected: ${_lastUniqueKey} -> ${widget.uniqueKey}');
      
      // Clear cache của profile cũ ngay lập tức
      _clearOldProfileCache(oldWidget.photos);
      
      // Reset controller và state
      _resetController();
      
      // Update tracking
      _lastUniqueKey = widget.uniqueKey;
    }
    
    widget.controller?._reset = resetToFirstImage;
  }

  // Clear cache của profile cũ
  void _clearOldProfileCache(List<PhotoModel> oldPhotos) {
    print('[IMAGE_DEBUG] Clearing cache for ${oldPhotos.length} old photos');
    
    // Sử dụng CacheCleanupService để clear cache triệt để
    CacheCleanupService.instance.clearAllCache();
  }

  // Reset controller
  void _resetController() {
    if (_isDisposed) return;
    
    print('[IMAGE_DEBUG] Resetting controller');
    
    // Dispose old controller
    _pageController?.dispose();
    
    // Reset state
    _currentIndex = 0;
    
    // Tạo controller mới
    _pageController = PageController(initialPage: 0);
  }

  void resetToFirstImage() {
    if (_isDisposed || _pageController?.hasClients != true) return;
    
    setState(() {
      _currentIndex = 0;
    });
    
    _pageController?.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onTapDown(TapDownDetails details, BoxConstraints constraints) {
    if (_isDisposed || _pageController?.hasClients != true) return;
    
    final dx = details.localPosition.dx;
    final width = constraints.maxWidth;
    final isLeftTap = dx < width / 2;
    
    int targetIndex = _currentIndex;
    
    if (isLeftTap && _currentIndex > 0) {
      targetIndex = _currentIndex - 1;
    } else if (!isLeftTap && _currentIndex < widget.photos.length - 1) {
      targetIndex = _currentIndex + 1;
    }
    
    if (targetIndex != _currentIndex) {
      setState(() {
        _currentIndex = targetIndex;
      });
      
      _pageController?.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
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
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (mounted && !_isDisposed) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
              itemBuilder: (context, index) {
                final photo = widget.photos[index];
                final imageUrl = photo.displayUrl;
                final uniqueKey = '${widget.uniqueKey}_${photo.id}_$index';
                
                return ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    key: ValueKey(uniqueKey),
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheHeight: 800,
                    memCacheWidth: 600,
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    placeholderFadeInDuration: Duration.zero,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                            color: i <= _currentIndex 
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
