// lib/infrastructure/services/image_precache_service.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/url_transformer.dart';
import '../../data/models/profile/photo_model.dart';
import '../../data/models/match/user_recommendation_model.dart';

/// Service để quản lý việc precache ảnh một cách hiệu quả
class ImagePrecacheService {
  static final ImagePrecacheService instance = ImagePrecacheService._internal();
  ImagePrecacheService._internal();

  final Set<String> _precachedUrls = <String>{};
  bool _isPrecaching = false;

  bool get isPrecaching => _isPrecaching;
  int get precachedCount => _precachedUrls.length;

  /// Precache tất cả ảnh của một profile
  Future<void> precacheProfileImages(UserRecommendationModel profile, BuildContext context) async {
    if (profile.photos.isEmpty) return;
    
    for (final photo in profile.photos) {
      await _precacheSingleImage(photo, context);
    }
  }

  /// Precache một ảnh cụ thể
  Future<void> _precacheSingleImage(PhotoModel photo, BuildContext context) async {
    try {
      final transformedUrl = UrlTransformer.transform(photo.url);
      
      // Kiểm tra xem ảnh đã được precache chưa
      if (_precachedUrls.contains(transformedUrl)) {
        print('ImagePrecacheService: Ảnh đã được precache: ${photo.id}');
        return;
      }
      
      final provider = CachedNetworkImageProvider(transformedUrl);
      await precacheImage(provider, context);
      
      _precachedUrls.add(transformedUrl);
      print('ImagePrecacheService: Đã precache ảnh: ${photo.id} - $transformedUrl');
    } catch (e) {
      print('ImagePrecacheService: Lỗi khi precache ảnh ${photo.id}: $e');
    }
  }

  /// Precache ảnh cho nhiều profiles
  Future<void> precacheMultipleProfiles(List<UserRecommendationModel> profiles, BuildContext context, {int count = 3}) async {
    if (_isPrecaching) {
      print('ImagePrecacheService: Đang precache, bỏ qua request mới');
      return;
    }

    if (profiles.isEmpty) {
      print('ImagePrecacheService: Không có profiles để precache');
      return;
    }

    _isPrecaching = true;
    print('ImagePrecacheService: Bắt đầu precache $count profiles...');

    try {
      final int profilesToPrecache = profiles.length > count ? count : profiles.length;
      
      for (int i = 0; i < profilesToPrecache; i++) {
        final profile = profiles[i];
        // Kiểm tra xem profile này đã được precache chưa
        if (!_isProfilePrecached(profile)) {
          await precacheProfileImages(profile, context);
        } else {
          print('ImagePrecacheService: Profile ${profile.userId} đã được precache, bỏ qua');
        }
      }
      
      print('ImagePrecacheService: Hoàn tất precache $profilesToPrecache profiles');
    } catch (e) {
      print('ImagePrecacheService: Lỗi khi precache multiple profiles: $e');
    } finally {
      _isPrecaching = false;
    }
  }

  /// Kiểm tra xem một profile đã được precache chưa
  bool _isProfilePrecached(UserRecommendationModel profile) {
    if (profile.photos.isEmpty) return true;
    
    // Kiểm tra xem tất cả ảnh của profile đã được precache chưa
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

  /// Clear tất cả precached URLs
  void clearPrecachedUrls() {
    _precachedUrls.clear();
    print('ImagePrecacheService: Đã clear tất cả precached URLs');
  }

  /// Get danh sách các URLs đã được precache
  Set<String> get precachedUrls => Set.from(_precachedUrls);
} 