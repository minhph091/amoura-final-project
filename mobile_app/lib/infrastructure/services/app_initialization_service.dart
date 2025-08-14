// lib/infrastructure/services/app_initialization_service.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/match_service.dart';
import '../../core/services/chat_service.dart';
import '../../infrastructure/socket/socket_client.dart';
import 'profile_buffer_service.dart';
import '../../data/models/match/user_recommendation_model.dart';
import 'image_precache_service.dart';
import '../../data/models/profile/photo_model.dart';

/// Service để chuẩn bị dữ liệu ngay từ đầu khi vào app
/// Đảm bảo khi user vào discovery thì dữ liệu đã sẵn sàng
class AppInitializationService {
  static final AppInitializationService instance = AppInitializationService._internal();
  AppInitializationService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;
  int? _currentUserId;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;
  int? get currentUserId => _currentUserId;

  /// Khởi tạo dữ liệu cần thiết cho app
  /// Gọi từ splash screen để chuẩn bị trước khi user vào main navigator
  Future<void> initializeAppData(BuildContext context) async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    print('AppInitializationService: Bắt đầu khởi tạo app data...');

    try {
      // 1. Load current user profile để lấy user ID và location
      await _loadCurrentUserProfile();
      
      // 2. Initialize WebSocket connection để user được đánh dấu online
      if (_currentUserId != null) {
        await _initializeWebSocketConnection();
      }
      
      // 3. Khởi tạo ProfileBufferService
      // Kiểm tra xem context còn valid không
      if (context.mounted) {
        await ProfileBufferService.instance.initialize();
        // Sau khi buffer có dữ liệu, precache ảnh của 1-3 profile đầu tiên
        try {
          final buffer = ProfileBufferService.instance.profiles;
          final int maxProfiles = buffer.length < 3 ? buffer.length : 3;
          for (int i = 0; i < maxProfiles; i++) {
            final photos = buffer[i].photos;
            // Lọc cover trước, sau đó đến highlights tương tự UI
            final coverList = photos.where((p) => p.type == 'profile_cover').toList();
            final cover = coverList.isNotEmpty ? coverList.first : null;
            final highlights = photos
                .where((p) => p.type == 'highlight')
                .toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            final displayPhotos = [if (cover != null) cover, ...highlights.take(4)];
            final int maxImages = displayPhotos.length.clamp(0, 5);
            for (int j = 0; j < maxImages; j++) {
              await ImagePrecacheService.instance.precacheImageUrl(displayPhotos[j].displayUrl, context);
            }
          }
        } catch (e) {
          print('AppInitializationService: Lỗi precache ảnh ban đầu - $e');
        }
      }
      
      _isInitialized = true;
      print('AppInitializationService: Khởi tạo hoàn tất');
    } catch (e) {
      print('AppInitializationService: Lỗi khởi tạo - $e');
      // Không throw error để không block việc vào app
    } finally {
      _isInitializing = false;
    }
  }

  /// Load current user profile để lấy thông tin cần thiết
  Future<void> _loadCurrentUserProfile() async {
    try {
      final profileService = GetIt.I<ProfileService>();
      final profileData = await profileService.getProfile();
      
      // Extract current user ID
      if (profileData['userId'] != null) {
        _currentUserId = profileData['userId'] as int;
        ProfileBufferService.instance.setCurrentUserId(_currentUserId);
        print('AppInitializationService: Set current user ID = $_currentUserId');
      }

      // Extract current user's interests (lowercased names) for common-interests precompute
      try {
        final List<String> currentUserInterestsLower =
            (profileData['interests'] as List<dynamic>? ?? [])
                .map((e) => (e['name'] as String?)?.toLowerCase() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();
        ProfileBufferService.instance.setCurrentUserInterestsLower(currentUserInterestsLower);
      } catch (e) {
        print('AppInitializationService: Lỗi parse interests current user - $e');
      }
    } catch (e) {
      print('AppInitializationService: Lỗi load current user - $e');
      // Không throw error để không block việc vào app
    }
  }

  /// Initialize WebSocket connection để user được đánh dấu online
  Future<void> _initializeWebSocketConnection() async {
    try {
      
      final socketClient = GetIt.I<SocketClient>();
      
      // TẠM THỜI TẮT TEST CONNECTION ĐỂ DEBUG LỖI
      // await socketClient.testConnection();
      
      await socketClient.connect(_currentUserId.toString());
      
    } catch (e) {
      print('AppInitializationService: Lỗi WebSocket - $e');
      // Không throw error để không block việc vào app
    }
  }

  /// Filter out current user's profile from recommendations
  List<UserRecommendationModel> _filterOutCurrentUser(List<UserRecommendationModel> recommendations) {
    if (_currentUserId == null) {
      return recommendations;
    }
    
    final filtered = recommendations.where((profile) => profile.userId != _currentUserId).toList();
    
    return filtered;
  }

  /// Reset trạng thái initialization (dùng khi logout)
  void reset() {
    _isInitialized = false;
    _isInitializing = false;
    _currentUserId = null;
    ProfileBufferService.instance.clear();
    ImagePrecacheService.instance.clearCache();
    
    // Disconnect WebSocket khi logout
    try {
      final socketClient = GetIt.I<SocketClient>();
      socketClient.disconnect();
    } catch (e) {
      print('AppInitializationService: Lỗi disconnect WebSocket - $e');
    }
    
    print('AppInitializationService: Reset hoàn tất');
  }
}
