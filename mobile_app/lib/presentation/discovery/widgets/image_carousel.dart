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
  // Notify parent when image index changes to update info sections accordingly
  final ValueChanged<int>? onImageIndexChanged;

  const ImageCarousel({
    super.key,
    required this.photos,
    this.showStoryProgress = false,
    this.controller,
    this.uniqueKey,
    this.onImageIndexChanged,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  PageController _pageController = PageController(keepPage: false);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupController();
    // Tránh lỗi MediaQuery trong initState: preload sau frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _preloadImages();
    });
  }

  @override
  void didUpdateWidget(ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset về ảnh đầu tiên khi profile thay đổi
    if (oldWidget.uniqueKey != widget.uniqueKey) {
      _resetToFirstImage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _preloadImages();
      });
    }
  }

  void _setupController() {
    widget.controller?._reset = _resetToFirstImage;
  }

  void _preloadImages() {
    // Preload tất cả ảnh của profile trong giới hạn hợp lý để đảm bảo chuyển ảnh mượt
    // Giới hạn tối đa 5 ảnh để tránh tốn bộ nhớ trên máy yếu
    final int maxPreload = widget.photos.length < 5 ? widget.photos.length : 5;
    for (int i = 0; i < maxPreload; i++) {
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
    if (mounted) {
      setState(() {
        _currentIndex = 0;
      });
      // Dùng jump để tránh nhấp nháy trước khi set profile mới
      _pageController.jumpToPage(0);
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
            // Thông báo cho parent để cập nhật phần thông tin theo ảnh hiện tại
            widget.onImageIndexChanged?.call(index);
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
