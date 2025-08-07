// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../infrastructure/services/profile_buffer_service.dart';
import '../../core/services/match_service.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/profile/interest_model.dart';
import '../../data/models/match/swipe_request_model.dart';
import '../../core/services/profile_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final ProfileBufferService _bufferService = ProfileBufferService.instance;
  final MatchService _matchService = GetIt.I<MatchService>();
  final ProfileService _profileService = GetIt.I<ProfileService>();

  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfiles => _bufferService.hasProfiles;
  
  UserRecommendationModel? get currentProfile => _bufferService.currentProfile;
  UserRecommendationModel? get nextProfile => _bufferService.nextProfile;
  
  List<InterestModel> getCurrentInterests() => _bufferService.getCurrentInterests();
  List<InterestModel> getNextInterests() => _bufferService.getNextInterests();
  String? getCurrentDistance() => _bufferService.getCurrentDistance();
  String? getNextDistance() => _bufferService.getNextDistance();

  /// Khởi tạo discovery
  Future<void> initialize() async {
    if (_isLoading) return;
    
    print('DiscoveryViewModel: Bắt đầu khởi tạo...');
    _setLoading(true);
    _clearError();
    
    try {
      // Load current user để set user ID
      await _loadCurrentUser();
      
      // Khởi tạo buffer service
      await _bufferService.initialize();
      
      print('DiscoveryViewModel: Khởi tạo hoàn tất');
      
    } catch (e) {
      print('DiscoveryViewModel: Lỗi khởi tạo - $e');
      _setError('Lỗi tải dữ liệu: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load current user info
  Future<void> _loadCurrentUser() async {
    try {
      final profileData = await _profileService.getProfile();
      final userId = profileData['userId'] as int?;
      
      if (userId != null) {
        _bufferService.setCurrentUserId(userId);
        print('DiscoveryViewModel: Set current user ID = $userId');
      }
    } catch (e) {
      print('DiscoveryViewModel: Lỗi load current user - $e');
      // Không throw error để không block discovery
    }
  }

  /// Like profile hiện tại
  Future<void> likeCurrentProfile() async {
    final profile = currentProfile;
    if (profile == null) return;
    
    print('DiscoveryViewModel: Like profile ${profile.userId}');
    
    try {
      // Gửi like request
      final request = SwipeRequestModel(
        targetUserId: profile.userId,
        isLike: true,
      );
      
      final response = await _matchService.swipeUser(request);
      
      if (response.isMatch) {
        print('DiscoveryViewModel: Match với profile ${profile.userId}!');
        // TODO: Show match dialog
      }
      
      // Chuyển sang profile tiếp theo
      await _moveToNextProfile();
      
    } catch (e) {
      print('DiscoveryViewModel: Lỗi like profile - $e');
      _setError('Lỗi like profile: $e');
    }
  }

  /// Pass profile hiện tại
  Future<void> passCurrentProfile() async {
    final profile = currentProfile;
    if (profile == null) return;
    
    print('DiscoveryViewModel: Pass profile ${profile.userId}');
    
    try {
      // Gửi pass request
      final request = SwipeRequestModel(
        targetUserId: profile.userId,
        isLike: false,
      );
      
      await _matchService.swipeUser(request);
      
      // Chuyển sang profile tiếp theo
      await _moveToNextProfile();
      
    } catch (e) {
      print('DiscoveryViewModel: Lỗi pass profile - $e');
      _setError('Lỗi pass profile: $e');
    }
  }

  /// Chuyển sang profile tiếp theo
  Future<void> _moveToNextProfile() async {
    await _bufferService.moveToNextProfile();
    notifyListeners();
    
    // Debug info
    _bufferService.printDebugInfo();
  }

  /// Callback khi swipe hoàn tất
  Future<void> onSwipeComplete() async {
    print('DiscoveryViewModel: Swipe completed');
    await _moveToNextProfile();
  }

  /// Rewind về profile trước đó
  Future<void> rewindToPreviousProfile() async {
    print('DiscoveryViewModel: Rewind to previous profile');
    
    try {
      // Implement logic để trở lại profile trước
      // Hiện tại chỉ log để debug
      bool success = await _bufferService.rewindToPrevious();
      if (success) {
        notifyListeners();
        _bufferService.printDebugInfo();
      } else {
        print('DiscoveryViewModel: Không thể rewind - không có profile trước đó');
      }
    } catch (e) {
      print('DiscoveryViewModel: Lỗi rewind - $e');
      _setError('Lỗi rewind: $e');
    }
  }

  /// Refresh toàn bộ discovery
  Future<void> refresh() async {
    print('DiscoveryViewModel: Refresh discovery...');
    _setLoading(true);
    _clearError();
    
    try {
      await _bufferService.refresh();
    } catch (e) {
      print('DiscoveryViewModel: Lỗi refresh - $e');
      _setError('Lỗi refresh: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Set error
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  /// Clear error
  void _clearError() {
    _setError(null);
  }

  @override
  void dispose() {
    print('DiscoveryViewModel: Dispose');
    super.dispose();
  }
}
