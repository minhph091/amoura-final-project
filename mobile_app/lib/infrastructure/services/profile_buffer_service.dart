// lib/infrastructure/services/profile_buffer_service.dart
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  // Precomputed common interests with current user (lowercase strings)
  final Map<int, List<String>> _profileCommonInterests = {};
  
  // Lưu trữ profiles đã xóa để có thể rewind
  final List<UserRecommendationModel> _removedProfiles = [];
  final Map<int, List<InterestModel>> _removedInterests = {};
  final Map<int, String?> _removedDistances = {};
  
  // Lưu trữ profiles đã swipe để không hiển thị lại
  final Set<int> _swipedProfileIds = <int>{};
  
  // Lưu trữ profiles đã like để không cho phép rewind
  final Set<int> _likedProfileIds = <int>{};
  
  // Profile hiện tại và profile tiếp theo
  int _currentIndex = 0;
  bool _isLoading = false;
  int? _currentUserId;
  List<String> _currentUserInterestsLower = <String>[];
  
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

  // Common interests getters
  List<String> getCurrentCommonInterests() {
    final profile = currentProfile;
    if (profile == null) return const [];
    return _profileCommonInterests[profile.userId] ?? const [];
  }

  List<String> getNextCommonInterests() {
    final profile = nextProfile;
    if (profile == null) return const [];
    return _profileCommonInterests[profile.userId] ?? const [];
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
    // Nếu đã có buffer sẵn thì không làm lại để giữ trải nghiệm hiển thị tức thì
    if (_profileBuffer.isNotEmpty) {
      print('ProfileBufferService: Buffer đã có sẵn ${_profileBuffer.length} profiles, bỏ qua khởi tạo lại');
      return;
    }
    
    print('ProfileBufferService: Bắt đầu khởi tạo buffer...');
    _isLoading = true;
    
    try {
      // Load swiped profiles từ storage
      await _loadSwipedProfiles();
      
      // Xóa buffer cũ
      clear();
      
      // Load profiles mới
      await _loadMoreProfiles();
      
      print('ProfileBufferService: Khởi tạo hoàn tất với ${_profileBuffer.length} profiles');
      print('ProfileBufferService: Đã swipe ${_swipedProfileIds.length} profiles trước đó');
    } catch (e) {
      print('ProfileBufferService: Lỗi khởi tạo - $e');
    } finally {
      _isLoading = false;
    }
  }
  
  /// Load danh sách profiles đã swipe từ SharedPreferences
  Future<void> _loadSwipedProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use user-specific key for swiped profiles
      final String key = _currentUserId != null 
          ? 'swiped_profile_ids_${_currentUserId}' 
          : 'swiped_profile_ids';
      
      // Migrate old data if exists (one-time migration)
      if (_currentUserId != null) {
        final oldKey = 'swiped_profile_ids';
        final oldSwipedIds = prefs.getStringList(oldKey);
        if (oldSwipedIds != null && oldSwipedIds.isNotEmpty) {
          // Migrate old data to new user-specific key
          await prefs.setStringList(key, oldSwipedIds);
          await prefs.remove(oldKey);
          print('ProfileBufferService: Migrated ${oldSwipedIds.length} swiped profiles from old key to user-specific key');
        }
      }
      
      final swipedIds = prefs.getStringList(key) ?? [];
      _swipedProfileIds.clear();
      _swipedProfileIds.addAll(swipedIds.map((id) => int.parse(id)));
      print('ProfileBufferService: Loaded ${_swipedProfileIds.length} swiped profiles from storage for user $_currentUserId');
    } catch (e) {
      print('ProfileBufferService: Error loading swiped profiles: $e');
    }
  }
  
  /// Lưu danh sách profiles đã swipe vào SharedPreferences
  Future<void> _saveSwipedProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final swipedIds = _swipedProfileIds.map((id) => id.toString()).toList();
      
      // Use user-specific key for swiped profiles
      final String key = _currentUserId != null 
          ? 'swiped_profile_ids_${_currentUserId}' 
          : 'swiped_profile_ids';
      
      await prefs.setStringList(key, swipedIds);
      print('ProfileBufferService: Saved ${_swipedProfileIds.length} swiped profiles to storage for user $_currentUserId');
    } catch (e) {
      print('ProfileBufferService: Error saving swiped profiles: $e');
    }
  }

  /// Load thêm profiles từ API
  Future<void> _loadMoreProfiles() async {
    try {
      final matchService = GetIt.I<MatchService>();
      final newProfiles = await matchService.getRecommendations();
      
      if (newProfiles.isEmpty) {
        print('ProfileBufferService: Không có profile mới từ API');
        // Khi không còn profile mới, thử nạp lại các profile đã pass một lần nữa
        if (_removedProfiles.isNotEmpty) {
          final List<UserRecommendationModel> requeue = _removedProfiles
              .where((p) => !_likedProfileIds.contains(p.userId))
              .toList();
          _removedProfiles.clear();
          for (final p in requeue) {
            // Chỉ thêm lại nếu chưa có trong buffer và chưa bị đánh dấu swiped (giữ behavior cũ)
            if (!_profileBuffer.any((e) => e.userId == p.userId)) {
              _profileBuffer.add(p);
              _profileInterests[p.userId] = p.interests;
              _profileDistances[p.userId] = _calculateDistance(p);
            }
          }
          print('ProfileBufferService: Đã nạp lại ${requeue.length} profiles đã pass');
        }
        return;
      }
      
      // Filter profiles (loại bỏ current user, profiles đã có, và profiles đã swipe)
      final filteredProfiles = newProfiles.where((profile) {
        // Loại bỏ current user
        if (_currentUserId != null && profile.userId == _currentUserId) {
          return false;
        }
        
        // Loại bỏ profiles đã có trong buffer
        if (_profileBuffer.any((existing) => existing.userId == profile.userId)) {
          return false;
        }
        
        // Loại bỏ profiles đã swipe (like/pass)
        if (_swipedProfileIds.contains(profile.userId)) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Thêm vào buffer
      for (final profile in filteredProfiles) {
        _profileBuffer.add(profile);
        _profileInterests[profile.userId] = profile.interests;
        _profileDistances[profile.userId] = _calculateDistance(profile);
        _profileCommonInterests[profile.userId] = _computeCommonInterests(profile);
      }
      
      print('ProfileBufferService: Buffer hiện có ${_profileBuffer.length} profiles');
      
    } catch (e) {
      print('ProfileBufferService: Lỗi load profiles - $e');
    }
  }

  /// Đánh dấu profile đã like
  void markProfileAsLiked(int profileId) {
    _likedProfileIds.add(profileId);
    debugPrint('ProfileBufferService: Marked profile $profileId as liked');
  }
  
  /// Đánh dấu profile đã pass (không like)
  void markProfileAsPassed(int profileId) {
    // Không thêm vào _likedProfileIds, chỉ vào _swipedProfileIds
    debugPrint('ProfileBufferService: Marked profile $profileId as passed');
  }

  /// Chuyển sang profile tiếp theo
  Future<void> moveToNextProfile() async {
    if (_profileBuffer.isEmpty) {
      print('ProfileBufferService: Buffer trống, không thể chuyển profile');
      return;
    }
    
    // Lưu profile hiện tại vào removed list để có thể rewind (chỉ khi không like)
    if (_currentIndex < _profileBuffer.length) {
      final removedProfile = _profileBuffer.removeAt(_currentIndex);
      final interests = _profileInterests.remove(removedProfile.userId);
      final distance = _profileDistances.remove(removedProfile.userId);
      
      // Đánh dấu profile đã được swipe
      _swipedProfileIds.add(removedProfile.userId);
      
      // Nếu profile này KHÔNG thuộc danh sách đã like, cho phép rewind
      if (!_likedProfileIds.contains(removedProfile.userId)) {
        _removedProfiles.add(removedProfile);
        if (interests != null) _removedInterests[removedProfile.userId] = interests;
        if (distance != null) _removedDistances[removedProfile.userId] = distance;
      }
      
      // Giới hạn số lượng removed profiles (chỉ giữ 10 profile gần nhất)
      if (_removedProfiles.length > 10) {
        final oldProfile = _removedProfiles.removeAt(0);
        _removedInterests.remove(oldProfile.userId);
        _removedDistances.remove(oldProfile.userId);
        // Không xóa khỏi _swipedProfileIds để tránh hiển thị lại
      }
      
      // Lưu swiped profiles vào storage
      await _saveSwipedProfiles();
      
      print('ProfileBufferService: Xóa profile ${removedProfile.userId}');
    }
    
    // Điều chỉnh index
    if (_currentIndex >= _profileBuffer.length && _profileBuffer.isNotEmpty) {
      _currentIndex = _profileBuffer.length - 1;
    }
    
    print('ProfileBufferService: Chuyển sang profile index $_currentIndex');
    print('ProfileBufferService: Buffer còn lại ${_profileBuffer.length} profiles');
    print('ProfileBufferService: Đã swipe ${_swipedProfileIds.length} profiles');
    
    // Load thêm profiles nếu buffer thấp
    if (_profileBuffer.length < 3 && !_isLoading) {
      print('ProfileBufferService: Buffer thấp, load thêm profiles...');
      await _loadMoreProfiles();
    }
  }

  /// Rewind về profile trước đó (chỉ profiles đã pass, không phải liked)
  Future<bool> rewindToPrevious() async {
    if (_removedProfiles.isEmpty) {
      debugPrint('ProfileBufferService: Không có profile nào để rewind');
      return false;
    }
    
    // Tìm profile gần nhất mà chưa bị like
    UserRecommendationModel? profileToRewind;
    int indexToRemove = -1;
    
    for (int i = _removedProfiles.length - 1; i >= 0; i--) {
      final profile = _removedProfiles[i];
      if (!_likedProfileIds.contains(profile.userId)) {
        profileToRewind = profile;
        indexToRemove = i;
        break;
      }
    }
    
    if (profileToRewind == null) {
      debugPrint('ProfileBufferService: Không có profile nào có thể rewind (tất cả đã like)');
      return false;
    }
    
    // Xóa profile từ removed list
    _removedProfiles.removeAt(indexToRemove);
    final interests = _removedInterests.remove(profileToRewind.userId);
    final distance = _removedDistances.remove(profileToRewind.userId);
    
    // Xóa khỏi danh sách đã swipe để có thể hiển thị lại
    _swipedProfileIds.remove(profileToRewind.userId);
    
    // Lưu thay đổi vào storage
    await _saveSwipedProfiles();
    
    // Thêm lại vào đầu buffer
    _profileBuffer.insert(0, profileToRewind);
    if (interests != null) _profileInterests[profileToRewind.userId] = interests;
    if (distance != null) _profileDistances[profileToRewind.userId] = distance;
    // Recompute common interests if missing
    _profileCommonInterests[profileToRewind.userId] =
        _profileCommonInterests[profileToRewind.userId] ?? _computeCommonInterests(profileToRewind);
    
    // Đặt current index về 0
    _currentIndex = 0;
    
    debugPrint('ProfileBufferService: Rewind thành công đến profile ${profileToRewind.userId}');
    debugPrint('ProfileBufferService: Buffer hiện tại ${_profileBuffer.length} profiles');
    
    return true;
  }

  /// Tính khoảng cách (placeholder - cần implement logic thực tế)
  String? _calculateDistance(UserRecommendationModel profile) {
    // TODO: Implement distance calculation based on location
    return null;
  }

  /// Set current user ID
  void setCurrentUserId(int? userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      print('ProfileBufferService: Set current user ID = $_currentUserId');
      
      // Reload swiped profiles for new user
      if (userId != null) {
        _loadSwipedProfiles();
      }
    }
  }

  /// Set current user's interests (lowercased names) to compute common interests
  void setCurrentUserInterestsLower(List<String> interestsLower) {
    _currentUserInterestsLower = interestsLower;
    print('ProfileBufferService: Set current user interests = ${_currentUserInterestsLower.length} items');
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
    _profileCommonInterests.clear();
    _currentIndex = 0;
    // Không xóa _swipedProfileIds để giữ trạng thái đã swipe
    print('ProfileBufferService: Đã xóa buffer (giữ lại ${_swipedProfileIds.length} swiped profiles)');
  }
  
  /// Reset toàn bộ (bao gồm swiped profiles) - chỉ dùng khi logout
  Future<void> resetAll() async {
    _profileBuffer.clear();
    _profileInterests.clear();
    _profileDistances.clear();
    _swipedProfileIds.clear();
    _likedProfileIds.clear();
    _removedProfiles.clear();
    _removedInterests.clear();
    _removedDistances.clear();
    _currentIndex = 0;
    
    // Xóa từ storage - use user-specific key
    final prefs = await SharedPreferences.getInstance();
    final String key = _currentUserId != null 
        ? 'swiped_profile_ids_${_currentUserId}' 
        : 'swiped_profile_ids';
    await prefs.remove(key);
    
    debugPrint('ProfileBufferService: Reset toàn bộ dữ liệu cho user $_currentUserId');
  }

  /// Debug info (removed spam logs)
  void printDebugInfo() {
    debugPrint('=== ProfileBufferService Debug Info ===');
    debugPrint('Current User ID: $_currentUserId');
    debugPrint('Current Index: $_currentIndex');
    debugPrint('Buffer Size: ${_profileBuffer.length}');
    debugPrint('Is Loading: $_isLoading');
    debugPrint('Swiped Profiles: ${_swipedProfileIds.length}');
    debugPrint('=========================================');
  }

  // Compute up to 3 common interests between current user and given profile
  List<String> _computeCommonInterests(UserRecommendationModel profile) {
    if (_currentUserInterestsLower.isEmpty) return const [];
    try {
      final recLower = profile.interests.map((i) => i.name.toLowerCase()).toList();
      final common = _currentUserInterestsLower
          .where((name) => recLower.contains(name))
          .take(3)
          .toList();
      return common;
    } catch (_) {
      return const [];
    }
  }
}
