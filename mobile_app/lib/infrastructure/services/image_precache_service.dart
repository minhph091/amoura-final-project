// lib/infrastructure/services/image_precache_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Service đơn giản để quản lý cache hình ảnh
class ImagePrecacheService {
  static final ImagePrecacheService instance = ImagePrecacheService._internal();
  ImagePrecacheService._internal();

  static const int maxPrecachedProfiles = 5;
  
  final Set<String> _cachedImages = <String>{};

  /// Precache một hình ảnh
  Future<void> precacheImageUrl(String imageUrl, BuildContext context) async {
    if (_cachedImages.contains(imageUrl)) return;
    
    try {
      await precacheImage(CachedNetworkImageProvider(imageUrl), context);
      _cachedImages.add(imageUrl);
      print('ImagePrecacheService: Precached image: $imageUrl');
    } catch (e) {
      print('ImagePrecacheService: Lỗi precache image $imageUrl - $e');
    }
  }

  /// Clear cache
  void clearCache() {
    _cachedImages.clear();
    print('ImagePrecacheService: Cleared cache');
  }

  /// Get cache stats
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImagesCount': _cachedImages.length,
      'maxPrecachedProfiles': maxPrecachedProfiles,
    };
  }
}
