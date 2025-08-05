// lib/infrastructure/services/cache_cleanup_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/match/user_recommendation_model.dart';

/// Service để quản lý việc clear cache một cách triệt để
/// Tránh hiện tượng nhấp nháy khi chuyển profile
class CacheCleanupService {
  static final CacheCleanupService instance = CacheCleanupService._internal();
  CacheCleanupService._internal();

  final Set<String> _clearedUrls = <String>{};
  final Set<int> _clearedProfiles = <int>{};

  /// Clear cache của một profile cụ thể
  void clearProfileCache(UserRecommendationModel profile) {
    // Tránh clear cache của cùng một profile nhiều lần
    if (_clearedProfiles.contains(profile.userId)) {
      return;
    }
    
    _clearedProfiles.add(profile.userId);
    
    // Clear cache của từng ảnh
    for (final photo in profile.photos) {
      if (photo.displayUrl.isNotEmpty && !_clearedUrls.contains(photo.displayUrl)) {
        CachedNetworkImage.evictFromCache(photo.displayUrl);
        _clearedUrls.add(photo.displayUrl);
      }
    }
    
    // Cleanup nếu quá nhiều URL đã được clear
    _cleanupClearedUrls();
  }

  /// Clear toàn bộ image cache một cách thông minh
  void _clearAllImageCache() {
    // Clear Flutter image cache
    imageCache.clear();
    imageCache.clearLiveImages();
    
    // Clear PaintingBinding image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Clear toàn bộ cache
  void clearAllCache() {
    _clearAllImageCache();
    _clearedUrls.clear();
    _clearedProfiles.clear();
  }

  /// Cleanup cleared URLs để tránh memory leak
  void _cleanupClearedUrls() {
    if (_clearedUrls.length > 1000) {
      _clearedUrls.clear();
    }
  }

  /// Reset cleared tracking
  void resetClearedTracking() {
    _clearedUrls.clear();
    _clearedProfiles.clear();
  }
} 