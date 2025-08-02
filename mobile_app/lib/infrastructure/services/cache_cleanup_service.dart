// lib/infrastructure/services/cache_cleanup_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/match/user_recommendation_model.dart';

/// Service để quản lý việc clear cache một cách triệt để
/// Tránh hiện tượng nhấp nháy khi chuyển profile
class CacheCleanupService {
  static final CacheCleanupService instance = CacheCleanupService._internal();
  CacheCleanupService._internal();

  /// Clear cache của một profile cụ thể
  void clearProfileCache(UserRecommendationModel profile) {
    print('[CACHE_CLEANUP] Clearing cache for profile ${profile.userId}');
    
    // Clear cache của từng ảnh
    for (final photo in profile.photos) {
      if (photo.displayUrl.isNotEmpty) {
        print('[CACHE_CLEANUP] Evicting: ${photo.displayUrl}');
        CachedNetworkImage.evictFromCache(photo.displayUrl);
      }
    }
    
    // Force clear toàn bộ image cache
    _clearAllImageCache();
  }

  /// Clear toàn bộ image cache
  void _clearAllImageCache() {
    print('[CACHE_CLEANUP] Clearing all image cache');
    
    // Clear Flutter image cache
    imageCache.clear();
    imageCache.clearLiveImages();
    
    // Clear PaintingBinding image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Clear memory cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clear toàn bộ cache
  void clearAllCache() {
    print('[CACHE_CLEANUP] Clearing all cache');
    _clearAllImageCache();
  }
} 