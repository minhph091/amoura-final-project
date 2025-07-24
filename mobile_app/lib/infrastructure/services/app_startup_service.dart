// lib/infrastructure/services/app_startup_service.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/auth_service.dart';
import 'app_initialization_service.dart';
import 'image_precache_service.dart';
import '../../presentation/discovery/discovery_recommendation_cache.dart';

/// Service để quản lý việc khởi tạo app một cách tổng thể
/// Đảm bảo tất cả dữ liệu cần thiết được chuẩn bị trước khi user vào main navigator
class AppStartupService {
  static final AppStartupService instance = AppStartupService._internal();
  AppStartupService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;
  bool get isInitializing => _isInitializing;

  /// Khởi tạo toàn bộ app
  /// Gọi từ splash screen để chuẩn bị tất cả dữ liệu cần thiết
  Future<void> initializeApp(BuildContext context) async {
    if (_isInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    print('AppStartupService: Bắt đầu khởi tạo app...');

    try {
      // 1. Kiểm tra authentication
      final authService = GetIt.I<AuthService>();
      final isAuthenticated = await authService.isAuthenticated();
      
      if (!isAuthenticated) {
        print('AppStartupService: User chưa authenticated, bỏ qua khởi tạo dữ liệu');
        _isInitialized = true;
        return;
      }

      // 2. Khởi tạo dữ liệu cần thiết
      // Kiểm tra xem context còn valid không
      if (context.mounted) {
        await AppInitializationService.instance.initializeAppData(context);
      } else {
        print('AppStartupService: Context không còn valid, bỏ qua khởi tạo dữ liệu');
      }
      
      _isInitialized = true;
      print('AppStartupService: Khởi tạo app hoàn tất');
    } catch (e) {
      print('AppStartupService: Lỗi khi khởi tạo app: $e');
      // Không throw error để không block việc vào app
    } finally {
      _isInitializing = false;
    }
  }

  /// Reset trạng thái khi logout
  void reset() {
    _isInitialized = false;
    _isInitializing = false;
    AppInitializationService.instance.reset();
    ImagePrecacheService.instance.clearPrecachedUrls();
    print('AppStartupService: Đã reset trạng thái');
  }

  /// Kiểm tra xem app đã sẵn sàng chưa
  bool get isReady => _isInitialized && AppInitializationService.instance.isInitialized;

  /// Get thông tin trạng thái khởi tạo
  Map<String, dynamic> get initializationStatus {
    return {
      'appStartupInitialized': _isInitialized,
      'appStartupInitializing': _isInitializing,
      'appDataInitialized': AppInitializationService.instance.isInitialized,
      'appDataInitializing': AppInitializationService.instance.isInitializing,
      'precachedImagesCount': ImagePrecacheService.instance.precachedCount,
      'precachedProfilesCount': ImagePrecacheService.instance.precachedProfilesCount,
      'isPrecaching': ImagePrecacheService.instance.isPrecaching,
      'cacheStatus': ImagePrecacheService.instance.getCacheStatus(),
    };
  }

  /// Kiểm tra performance của app
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'initializationTime': DateTime.now().millisecondsSinceEpoch,
      'cacheEfficiency': {
        'precachedImages': ImagePrecacheService.instance.precachedCount,
        'precachedProfiles': ImagePrecacheService.instance.precachedProfilesCount,
        'cacheHitRate': _calculateCacheHitRate(),
      },
      'memoryUsage': {
        'maxPrecachedProfiles': ImagePrecacheService.maxPrecachedProfiles,
        'currentPrecachedProfiles': ImagePrecacheService.instance.precachedProfilesCount,
      },
    };
  }

  /// Tính toán cache hit rate (tỷ lệ cache hit)
  double _calculateCacheHitRate() {
    final cacheStatus = ImagePrecacheService.instance.getCacheStatus();
    final precachedProfiles = cacheStatus['precachedProfilesCount'] as int;
    final totalProfiles = RecommendationCache.instance.recommendations?.length ?? 0;
    
    if (totalProfiles == 0) return 0.0;
    return (precachedProfiles / totalProfiles).clamp(0.0, 1.0);
  }
} 