// lib/infrastructure/services/profile_transition_manager.dart
import 'package:flutter/material.dart';
import '../../data/models/match/user_recommendation_model.dart';
import 'cache_cleanup_service.dart';

/// Service để quản lý việc transition giữa các profile một cách mượt mà
/// Tránh hiện tượng nhấp nháy khi chuyển profile
class ProfileTransitionManager {
  static final ProfileTransitionManager instance = ProfileTransitionManager._internal();
  ProfileTransitionManager._internal();

  UserRecommendationModel? _currentProfile;
  UserRecommendationModel? _nextProfile;
  bool _isTransitioning = false;
  final Set<int> _processedProfiles = <int>{};

  /// Bắt đầu transition - clear cache profile hiện tại
  void startTransition(UserRecommendationModel currentProfile) {
    _currentProfile = currentProfile;
    _isTransitioning = true;
    
    // Clear cache ngay lập tức
    CacheCleanupService.instance.clearProfileCache(currentProfile);
  }

  /// Kết thúc transition - clear cache profile cũ
  void endTransition(UserRecommendationModel newProfile) {
    if (_currentProfile != null && _currentProfile!.userId != newProfile.userId) {
      // Clear cache profile cũ
      CacheCleanupService.instance.clearProfileCache(_currentProfile!);
      _processedProfiles.add(_currentProfile!.userId);
    }
    
    _currentProfile = newProfile;
    _nextProfile = null;
    _isTransitioning = false;
  }

  /// Set profile tiếp theo để chuẩn bị
  void setNextProfile(UserRecommendationModel? nextProfile) {
    _nextProfile = nextProfile;
  }

  /// Clear toàn bộ cache khi cần thiết
  void clearAllCache() {
    CacheCleanupService.instance.clearAllCache();
    _processedProfiles.clear();
  }

  /// Reset state
  void reset() {
    _currentProfile = null;
    _nextProfile = null;
    _isTransitioning = false;
    _processedProfiles.clear();
  }

  /// Kiểm tra xem profile đã được xử lý chưa
  bool isProfileProcessed(int userId) {
    return _processedProfiles.contains(userId);
  }

  /// Clear processed profile để tránh memory leak
  void clearProcessedProfiles() {
    if (_processedProfiles.length > 100) {
      _processedProfiles.clear();
    }
  }

  bool get isTransitioning => _isTransitioning;
  UserRecommendationModel? get currentProfile => _currentProfile;
  UserRecommendationModel? get nextProfile => _nextProfile;
} 