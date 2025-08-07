// lib/infrastructure/services/profile_buffer_service.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/match_service.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/profile/interest_model.dart';

/// Dịch vụ quản lý buffer profile cho discovery
/// Luôn duy trì sẵn 5 profile để hiển thị mượt mà
class ProfileBufferService {
  static final ProfileBufferService instance = ProfileBufferService._internal();
  ProfileBufferService._internal();

  // Buffer profiles - luôn duy trì 5 profile sẵn sàng
  final List<UserRecommendationModel> _profileBuffer = [];
  final Map<int, List<InterestModel>> _profileInterests = {};
  final Map<int, String?> _profileDistances = {};
  
  // Lưu trữ profiles đã xóa để có thể rewind
  final List<UserRecommendationModel> _removedProfiles = [];
  final Map<int, List<InterestModel>> _removedInterests = {};
  final Map<int, String?> _removedDistances = {};
  
  // Profile hiện tại và profile tiếp theo
  int _currentIndex = 0;
  bool _isLoading = false;
  int? _currentUserId;
  
  // Getters
  List<UserRecommendationModel> get profiles => List.unmodifiable(_profileBuffer);
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get hasProfiles => _profileBuffer.isNotEmpty;
  bool get hasNextProfile => _currentIndex < _profileBuffer.length - 1 || _profileBuffer.length >= 5;
  
  // Current profile
  UserRecommendationModel? get currentProfile => 
    _currentIndex < _profileBuffer.length ? _profileBuffer[_currentIndex] : null;
  
  // Next profile  
  UserRecommendationModel? get nextProfile => 
    _currentIndex + 1 < _profileBuffer.length ? _profileBuffer[_currentIndex + 1] : null;
  
  // Profile interests
  List<InterestModel> getCurrentInterests() {
    final profile = currentProfile;
    if (profile == null) return [];
    return _profileInterests[profile.userId] ?? profile.interests;
  }
  
  List<InterestModel> getNextInterests() {
    final profile = nextProfile;
    if (profile == null) return [];
    return _profileInterests[profile.userId] ?? profile.interests;
  }
  
  // Profile distances
  String? getCurrentDistance() {
    final profile = currentProfile;
    if (profile == null) return null;
    return _profileDistances[profile.userId];
  }
  
  String? getNextDistance() {
    final profile = nextProfile;
    if (profile == null) return null;
    return _profileDistances[profile.userId];
  }

  /// Khởi tạo buffer với profiles ban đầu
  Future<void> initialize() async {
    if (_isLoading) return;
    
    print('ProfileBufferService: Bắt đầu khởi tạo buffer...');
    _isLoading = true;
    
    try {
      // Xóa buffer cũ
      clear();
      
      // Load profiles mới
      await _loadMoreProfiles();
      
      print('ProfileBufferService: Khởi tạo hoàn tất với ${_profileBuffer.length} profiles');
    } catch (e) {
      print('ProfileBufferService: Lỗi khởi tạo - $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Load thêm profiles từ API
  Future<void> _loadMoreProfiles() async {
    try {
      final matchService = GetIt.I<MatchService>();
      final newProfiles = await matchService.getRecommendations();
      
      if (newProfiles.isEmpty) {
        print('ProfileBufferService: Không có profile mới từ API');
        return;
      }
      
      // Filter profiles (loại bỏ current user và profiles đã có)
      final filteredProfiles = newProfiles.where((profile) {
        // Loại bỏ current user
        if (_currentUserId != null && profile.userId == _currentUserId) {
          return false;
        }
        
        // Loại bỏ profiles đã có trong buffer
        return !_profileBuffer.any((existing) => existing.userId == profile.userId);
      }).toList();
      
      // Thêm vào buffer
      for (final profile in filteredProfiles) {
        _profileBuffer.add(profile);
        _profileInterests[profile.userId] = profile.interests;
        _profileDistances[profile.userId] = _calculateDistance(profile);
        
        print('ProfileBufferService: Thêm profile ${profile.userId} - ${profile.firstName} ${profile.lastName}');
      }
      
      print('ProfileBufferService: Buffer hiện có ${_profileBuffer.length} profiles');
      
    } catch (e) {
      print('ProfileBufferService: Lỗi load profiles - $e');
    }
  }

  /// Chuyển sang profile tiếp theo
  Future<void> moveToNextProfile() async {
    if (_profileBuffer.isEmpty) {
      print('ProfileBufferService: Buffer trống, không thể chuyển profile');
      return;
    }
    
    // Lưu profile hiện tại vào removed list để có thể rewind
    if (_currentIndex < _profileBuffer.length) {
      final removedProfile = _profileBuffer.removeAt(_currentIndex);
      final interests = _profileInterests.remove(removedProfile.userId);
      final distance = _profileDistances.remove(removedProfile.userId);
      
      // Lưu vào removed lists
      _removedProfiles.add(removedProfile);
      if (interests != null) _removedInterests[removedProfile.userId] = interests;
      if (distance != null) _removedDistances[removedProfile.userId] = distance;
      
      // Giới hạn số lượng removed profiles (chỉ giữ 10 profile gần nhất)
      if (_removedProfiles.length > 10) {
        final oldProfile = _removedProfiles.removeAt(0);
        _removedInterests.remove(oldProfile.userId);
        _removedDistances.remove(oldProfile.userId);
      }
      
      print('ProfileBufferService: Xóa profile ${removedProfile.userId}');
    }
    
    // Điều chỉnh index
    if (_currentIndex >= _profileBuffer.length && _profileBuffer.isNotEmpty) {
      _currentIndex = _profileBuffer.length - 1;
    }
    
    print('ProfileBufferService: Chuyển sang profile index $_currentIndex');
    print('ProfileBufferService: Buffer còn lại ${_profileBuffer.length} profiles');
    
    // Load thêm profiles nếu buffer thấp
    if (_profileBuffer.length < 3 && !_isLoading) {
      print('ProfileBufferService: Buffer thấp, load thêm profiles...');
      await _loadMoreProfiles();
    }
  }

  /// Rewind về profile trước đó
  Future<bool> rewindToPrevious() async {
    if (_removedProfiles.isEmpty) {
      print('ProfileBufferService: Không có profile nào để rewind');
      return false;
    }
    
    // Lấy profile cuối cùng từ removed list
    final previousProfile = _removedProfiles.removeLast();
    final interests = _removedInterests.remove(previousProfile.userId);
    final distance = _removedDistances.remove(previousProfile.userId);
    
    // Thêm lại vào đầu buffer
    _profileBuffer.insert(0, previousProfile);
    if (interests != null) _profileInterests[previousProfile.userId] = interests;
    if (distance != null) _profileDistances[previousProfile.userId] = distance;
    
    // Đặt current index về 0
    _currentIndex = 0;
    
    print('ProfileBufferService: Rewind thành công đến profile ${previousProfile.userId}');
    print('ProfileBufferService: Buffer hiện tại ${_profileBuffer.length} profiles');
    
    return true;
  }

  /// Tính khoảng cách (placeholder - cần implement logic thực tế)
  String? _calculateDistance(UserRecommendationModel profile) {
    // TODO: Implement distance calculation based on location
    return null;
  }

  /// Set current user ID
  void setCurrentUserId(int? userId) {
    _currentUserId = userId;
    print('ProfileBufferService: Set current user ID = $_currentUserId');
  }

  /// Refresh toàn bộ buffer
  Future<void> refresh() async {
    print('ProfileBufferService: Refresh buffer...');
    clear();
    await initialize();
  }

  /// Xóa toàn bộ buffer
  void clear() {
    _profileBuffer.clear();
    _profileInterests.clear();
    _profileDistances.clear();
    _currentIndex = 0;
    print('ProfileBufferService: Đã xóa buffer');
  }

  /// Debug info
  void printDebugInfo() {
    print('=== ProfileBufferService Debug Info ===');
    print('Current User ID: $_currentUserId');
    print('Current Index: $_currentIndex');
    print('Buffer Size: ${_profileBuffer.length}');
    print('Is Loading: $_isLoading');
    
    for (int i = 0; i < _profileBuffer.length; i++) {
      final profile = _profileBuffer[i];
      final marker = i == _currentIndex ? ' <- CURRENT' : '';
      print('[$i] Profile ${profile.userId} - ${profile.firstName} ${profile.lastName}$marker');
    }
    print('=========================================');
  }
}
