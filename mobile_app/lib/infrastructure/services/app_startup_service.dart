// lib/infrastructure/services/app_startup_service.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/auth_service.dart';
import 'app_initialization_service.dart';
import 'image_precache_service.dart';
import 'profile_buffer_service.dart';

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
    ImagePrecacheService.instance.clearCache();
    print('AppStartupService: Đã reset trạng thái');
  }

  /// Kiểm tra xem app đã sẵn sàng chưa
  bool get isReady => _isInitialized && AppInitializationService.instance.isInitialized;

  /// Get thông tin trạng thái khởi tạo
  Map<String, dynamic> get initializationStatus {
    final cacheStats = ImagePrecacheService.instance.getCacheStats();
    return {
      'appStartupInitialized': _isInitialized,
      'appStartupInitializing': _isInitializing,
      'appDataInitialized': AppInitializationService.instance.isInitialized,
      'appDataInitializing': AppInitializationService.instance.isInitializing,
      'cacheStatus': cacheStats,
    };
  }

  /// Kiểm tra performance của app
  Map<String, dynamic> getPerformanceMetrics() {
    final cacheStats = ImagePrecacheService.instance.getCacheStats();
    return {
      'initializationTime': DateTime.now().millisecondsSinceEpoch,
      'cacheEfficiency': {
        'precachedImages': cacheStats['precachedUrls'] ?? 0,
        'precachedProfiles': cacheStats['precachedProfiles'] ?? 0,
        'cacheHitRate': _calculateCacheHitRate(),
      },
      'memoryUsage': {
        'maxPrecachedProfiles': ImagePrecacheService.maxPrecachedProfiles,
        'currentPrecachedProfiles': cacheStats['precachedProfiles'] ?? 0,
      },
    };
  }

  /// Tính toán cache hit rate (tỷ lệ cache hit)
  double _calculateCacheHitRate() {
    final cacheStats = ImagePrecacheService.instance.getCacheStats();
    final precachedProfiles = cacheStats['precachedProfiles'] as int? ?? 0;
    final totalProfiles = ProfileBufferService.instance.profiles.length;
    
    if (totalProfiles == 0) return 0.0;
    return (precachedProfiles / totalProfiles).clamp(0.0, 1.0);
  }
} 