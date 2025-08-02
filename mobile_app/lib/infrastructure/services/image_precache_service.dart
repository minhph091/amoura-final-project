// lib/infrastructure/services/image_precache_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/url_transformer.dart';
import '../../data/models/profile/photo_model.dart';
import '../../data/models/match/user_recommendation_model.dart';

/// Service để quản lý việc precache ảnh một cách hiệu quả
/// Tối ưu hóa cho trải nghiệm vuốt mượt mà như Tinder
class ImagePrecacheService {
  static final ImagePrecacheService instance = ImagePrecacheService._internal();
  ImagePrecacheService._internal();

  final Set<String> _precachedUrls = <String>{};
  final Map<int, List<String>> _profileImageUrls = <int, List<String>>{};
  bool _isPrecaching = false;
  
  // Cấu hình precache
  static const int maxPrecachedProfiles = 15; // Tăng từ 3 lên 15
  static const int precacheThreshold = 3; // Bắt đầu precache khi còn 3 profile
  static const int precacheBatchSize = 5; // Precache 5 profile một lần

  bool get isPrecaching => _isPrecaching;
  int get precachedCount => _precachedUrls.length;
  int get precachedProfilesCount => _profileImageUrls.length;

  /// Precache tất cả ảnh của một profile
  Future<void> precacheProfileImages(UserRecommendationModel profile, BuildContext context) async {
    if (profile.photos.isEmpty) return;
    
    final profileUrls = <String>[];
    for (final photo in profile.photos) {
      await _precacheSingleImage(photo, context);
      // Sử dụng cacheUrl thay vì transform để đảm bảo consistency
      profileUrls.add(photo.cacheUrl);
    }
    
    // Track URLs cho profile này
    _profileImageUrls[profile.userId] = profileUrls;
    
    // Cleanup nếu quá nhiều profile được cache
    _cleanupExcessProfiles();
  }

  /// Precache một ảnh đơn lẻ
  Future<void> _precacheSingleImage(PhotoModel photo, BuildContext context) async {
    // Sử dụng cacheUrl thay vì transform để đảm bảo consistency
    final imageUrl = photo.cacheUrl;
    
    if (_precachedUrls.contains(imageUrl)) return;
    
    try {
      final provider = CachedNetworkImageProvider(imageUrl);
      await precacheImage(provider, context);
      _precachedUrls.add(imageUrl);
    } catch (e) {
      // Log error nhưng không throw để không ảnh hưởng đến UX
      debugPrint('ImagePrecacheService: Lỗi khi precache ảnh $imageUrl: $e');
    }
  }

  /// Precache nhiều profile cùng lúc
  Future<void> precacheMultipleProfiles(
    List<UserRecommendationModel> profiles, 
    BuildContext context, 
    {int count = 5}
  ) async {
    if (_isPrecaching) return;
    
    _isPrecaching = true;
    final profilesToCache = profiles.take(count).toList();
    
    try {
      for (final profile in profilesToCache) {
        await precacheProfileImages(profile, context);
      }
    } finally {
      _isPrecaching = false;
    }
  }

  /// Precache cho discovery view
  Future<void> precacheForDiscovery(
    List<UserRecommendationModel> profiles, 
    BuildContext context
  ) async {
    if (profiles.isEmpty) return;
    
    // Precache 4 profile đầu tiên cho trải nghiệm mượt mà
    final initialProfiles = profiles.take(4).toList();
    await precacheMultipleProfiles(initialProfiles, context, count: initialProfiles.length);
  }

  /// Precache batch tiếp theo
  Future<void> precacheNextBatch(
    List<UserRecommendationModel> profiles, 
    int currentIndex, 
    BuildContext context
  ) async {
    if (currentIndex >= profiles.length - 2) return;
    
    final nextProfiles = profiles.skip(currentIndex + 2).take(3).toList();
    if (nextProfiles.isNotEmpty) {
      await precacheMultipleProfiles(nextProfiles, context, count: nextProfiles.length);
    }
  }

  /// Remove profile from cache
  void removeProfileFromCache(int userId) {
    final urls = _profileImageUrls.remove(userId);
    if (urls != null) {
      for (final url in urls) {
        _precachedUrls.remove(url);
        // Clear cache trực tiếp
        CachedNetworkImage.evictFromCache(url);
      }
    }
  }

  /// Clear all cache
  void clearCache() {
    _precachedUrls.clear();
    _profileImageUrls.clear();
    // Force clear image cache
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  /// Check if profile is precached
  bool isProfilePrecached(UserRecommendationModel profile) {
    return _profileImageUrls.containsKey(profile.userId);
  }

  /// Cleanup excess profiles để tránh memory leak
  void _cleanupExcessProfiles() {
    if (_profileImageUrls.length <= maxPrecachedProfiles) return;
    
    final sortedProfiles = _profileImageUrls.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    final profilesToRemove = sortedProfiles.take(_profileImageUrls.length - maxPrecachedProfiles);
    
    for (final entry in profilesToRemove) {
      removeProfileFromCache(entry.key);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'precachedUrls': _precachedUrls.length,
      'precachedProfiles': _profileImageUrls.length,
      'isPrecaching': _isPrecaching,
    };
  }
} 

