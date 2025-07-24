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
      profileUrls.add(UrlTransformer.transform(photo.url));
    }
    
    // Track URLs cho profile này
    _profileImageUrls[profile.userId] = profileUrls;
    
    // Cleanup nếu quá nhiều profile được cache
    _cleanupExcessProfiles();
  }

  /// Precache một ảnh cụ thể
  Future<void> _precacheSingleImage(PhotoModel photo, BuildContext context) async {
    try {
      final transformedUrl = UrlTransformer.transform(photo.url);
      
      // Kiểm tra xem ảnh đã được precache chưa
      if (_precachedUrls.contains(transformedUrl)) {
        return;
      }
      
      final provider = CachedNetworkImageProvider(transformedUrl);
      await precacheImage(provider, context);
      
      _precachedUrls.add(transformedUrl);
    } catch (e) {
      // print('ImagePrecacheService: Lỗi khi precache ảnh ${photo.id}: $e');
    }
  }

  /// Precache ảnh cho nhiều profiles với logic thông minh
  Future<void> precacheMultipleProfiles(List<UserRecommendationModel> profiles, BuildContext context, {int count = 5}) async {
    if (_isPrecaching) {
      return;
    }

    if (profiles.isEmpty) {
      return;
    }

    _isPrecaching = true;

    try {
      final int profilesToPrecache = profiles.length > count ? count : profiles.length;
      
      for (int i = 0; i < profilesToPrecache; i++) {
        final profile = profiles[i];
        // Kiểm tra xem profile này đã được precache chưa
        if (!isProfilePrecached(profile)) {
          await precacheProfileImages(profile, context);
          // Thêm delay nhỏ để không block UI
          await Future.delayed(const Duration(milliseconds: 50));
        }
      }
      
    } catch (e) {
      // print('ImagePrecacheService: Lỗi khi precache multiple profiles: $e');
    } finally {
      _isPrecaching = false;
    }
  }

  /// Precache thông minh cho discovery - precache nhiều profile hơn
  Future<void> precacheForDiscovery(List<UserRecommendationModel> profiles, BuildContext context) async {
    if (profiles.isEmpty) return;
    
    // Precache 10 profile đầu tiên thay vì 3
    final int initialPrecacheCount = profiles.length > 10 ? 10 : profiles.length;
    await precacheMultipleProfiles(profiles, context, count: initialPrecacheCount);
  }

  /// Precache thêm khi user đã vuốt qua một số profile
  Future<void> precacheNextBatch(List<UserRecommendationModel> profiles, int currentIndex, BuildContext context) async {
    if (profiles.isEmpty || currentIndex >= profiles.length) return;
    
    // Tính toán vị trí bắt đầu precache batch tiếp theo
    final startIndex = currentIndex + 1;
    final endIndex = (startIndex + precacheBatchSize) < profiles.length 
        ? startIndex + precacheBatchSize 
        : profiles.length;
    
    if (startIndex >= endIndex) return;
    
    final nextProfiles = profiles.sublist(startIndex, endIndex);
    
    await precacheMultipleProfiles(nextProfiles, context, count: nextProfiles.length);
  }

  /// Kiểm tra xem một profile đã được precache chưa
  bool isProfilePrecached(UserRecommendationModel profile) {
    if (profile.photos.isEmpty) return true;
    for (final photo in profile.photos) {
      if (!isUrlPrecached(photo.url)) {
        return false;
      }
    }
    return true;
  }

  /// Kiểm tra xem một URL đã được precache chưa
  bool isUrlPrecached(String url) {
    final transformedUrl = UrlTransformer.transform(url);
    return _precachedUrls.contains(transformedUrl);
  }

  /// Cleanup profiles đã cache quá nhiều
  void _cleanupExcessProfiles() {
    if (_profileImageUrls.length <= maxPrecachedProfiles) return;
    
    // Xóa profile cũ nhất
    final oldestProfileId = _profileImageUrls.keys.first;
    final urlsToRemove = _profileImageUrls[oldestProfileId] ?? [];
    
    for (final url in urlsToRemove) {
      _precachedUrls.remove(url);
    }
    
    _profileImageUrls.remove(oldestProfileId);
  }

  /// Xóa cache cho profile đã vuốt qua
  void removeProfileFromCache(int profileId) {
    final urlsToRemove = _profileImageUrls[profileId] ?? [];
    
    for (final url in urlsToRemove) {
      _precachedUrls.remove(url);
    }
    
    _profileImageUrls.remove(profileId);
  }

  /// Xóa tất cả cache
  void clearPrecachedUrls() {
    _precachedUrls.clear();
    _profileImageUrls.clear();
  }

  /// Lấy thông tin cache status
  Map<String, dynamic> getCacheStatus() {
    return {
      'precachedUrlsCount': _precachedUrls.length,
      'precachedProfilesCount': _profileImageUrls.length,
      'isPrecaching': _isPrecaching,
      'precachedProfileIds': _profileImageUrls.keys.toList(),
    };
  }
} 
