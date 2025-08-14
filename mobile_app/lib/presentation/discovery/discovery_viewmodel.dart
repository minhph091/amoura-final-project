// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get_it/get_it.dart';
import '../../infrastructure/services/profile_buffer_service.dart';
import '../../core/services/match_service.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/profile/interest_model.dart';
import '../../data/models/match/swipe_request_model.dart';
import '../../data/models/match/swipe_response_model.dart';
import '../../core/services/profile_service.dart';
import 'widgets/match_dialog.dart';
import '../../core/services/chat_service.dart';
import '../../app/routes/app_routes.dart';
import '../../infrastructure/services/sound_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  final ProfileBufferService _bufferService = ProfileBufferService.instance;
  final MatchService _matchService = GetIt.I<MatchService>();
  final ProfileService _profileService = GetIt.I<ProfileService>();
  final SoundService _soundService = GetIt.I<SoundService>();
  final ChatService _chatService = GetIt.I<ChatService>();

  bool _isLoading = false;
  String? _error;
  BuildContext? _context;

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
  List<String> getCurrentCommonInterests() => _bufferService.getCurrentCommonInterests();
  List<String> getNextCommonInterests() => _bufferService.getNextCommonInterests();

  /// Set context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Khởi tạo discovery
  Future<void> initialize() async {
    if (_isLoading) return;
    
    print('DiscoveryViewModel: Bắt đầu khởi tạo...');
    _clearError();
    // Nếu buffer đã có sẵn profiles (được chuẩn bị từ Splash/AppStartup),
    // thì bỏ qua việc re-initialize để tránh nháy/loading không cần thiết
    if (_bufferService.hasProfiles) {
      print('DiscoveryViewModel: Buffer đã sẵn sàng, bỏ qua khởi tạo lại');
      _setLoading(false);
      notifyListeners();
      return;
    }

    _setLoading(true);
    
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
    
    debugPrint('DiscoveryViewModel: Like profile ${profile.userId}');
    
    try {
      // Play SFX for like
      unawaited(_soundService.playSwipeLike());
      // Đánh dấu profile đã like để không cho phép rewind
      _bufferService.markProfileAsLiked(profile.userId);
      // Chuyển UI sang profile tiếp theo ngay lập tức để tránh giật
      // Thực hiện API ở nền
      unawaited(_moveToNextProfile());

      // Gửi like request ở nền
      unawaited(() async {
        try {
          final request = SwipeRequestModel(
            targetUserId: profile.userId,
            isLike: true,
          );
          final response = await _matchService.swipeUser(request);
          if (response.isMatch) {
            // Celebrate match
            unawaited(_soundService.playMatchSuccess());
            debugPrint('DiscoveryViewModel: Match detected with profile ${profile.userId}!');
            debugPrint('DiscoveryViewModel: Match response: ${response.toJson()}');
            await _showMatchDialog(profile, response);
          }
        } catch (e) {
          debugPrint('DiscoveryViewModel: Lỗi like profile (nền) - $e');
        }
      }());
      
    } catch (e) {
      debugPrint('DiscoveryViewModel: Lỗi like profile - $e');
      _setError('Lỗi like profile: $e');
    }
  }

  /// Pass profile hiện tại
  Future<void> passCurrentProfile() async {
    final profile = currentProfile;
    if (profile == null) return;
    
    debugPrint('DiscoveryViewModel: Pass profile ${profile.userId}');
    
    try {
      // Play SFX for pass
      unawaited(_soundService.playSwipePass());
      // Đánh dấu profile đã pass (cho phép rewind)
      _bufferService.markProfileAsPassed(profile.userId);

      // Chuyển UI sang profile tiếp theo ngay lập tức
      unawaited(_moveToNextProfile());

      // Gửi pass request ở nền (không block UI)
      unawaited(() async {
        try {
          final request = SwipeRequestModel(
            targetUserId: profile.userId,
            isLike: false,
          );
          await _matchService.swipeUser(request);
        } catch (e) {
          debugPrint('DiscoveryViewModel: Lỗi pass profile (nền) - $e');
        }
      }());
      
    } catch (e) {
      debugPrint('DiscoveryViewModel: Lỗi pass profile - $e');
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

  /// Hiển thị dialog match
  Future<void> _showMatchDialog(UserRecommendationModel profile, SwipeResponseModel response) async {
    if (_context == null) {
      print('DiscoveryViewModel: Context is null, cannot show match dialog');
      return;
    }

    print('DiscoveryViewModel: ITS A MATCH! with ${profile.firstName} ${profile.lastName}');
    
    try {
      // Get current user avatar URL (you can implement this if needed)
      String? currentUserAvatarUrl;
      
      await showMatchDialog(
        _context!,
        response,
        profile,
        currentUserAvatarUrl,
        onStartChat: () {
          // Navigate to chat
          print('DiscoveryViewModel: Navigate to chat with ${profile.firstName}');
          _navigateToChat(response.chatRoomId, profile);
        },
      );
    } catch (e) {
      print('DiscoveryViewModel: Error showing match dialog - $e');
    }
  }

  /// Navigate to chat room
  void _navigateToChat(int? chatRoomId, UserRecommendationModel profile) {
    if (chatRoomId == null) {
      print('DiscoveryViewModel: Chat room ID is null');
      return;
    }
    
    // Seed chat để Chat List xuất hiện ngay lập tức
    _chatService.seedChatFromMatch(
      chatRoomId.toString(),
      profile.userId.toString(),
      '${profile.firstName} ${profile.lastName}'.trim(),
    );

    print('DiscoveryViewModel: Navigate to chat room $chatRoomId with ${profile.firstName}');
    if (_context != null) {
      Navigator.pushNamed(
        _context!,
        AppRoutes.chatConversation,
        arguments: {
          'chatId': chatRoomId.toString(),
          'recipientName': '${profile.firstName} ${profile.lastName}'.trim(),
          'recipientAvatar': null,
          'isOnline': false,
        },
      );
    }
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
