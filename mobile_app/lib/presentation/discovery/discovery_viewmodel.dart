// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/url_transformer.dart';
import '../../core/utils/distance_calculator.dart';
import '../../../config/language/app_localizations.dart';
import '../../data/models/profile/interest_model.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/match/swipe_response_model.dart';
import '../../domain/models/match/liked_user_model.dart';
import '../../core/services/match_service.dart';
import '../../core/services/profile_service.dart';
import '../../infrastructure/services/rewind_service.dart';
import '../discovery/widgets/match_dialog.dart';
import 'discovery_recommendation_cache.dart';
import '../../../app/routes/app_routes.dart';
import '../../../infrastructure/services/app_initialization_service.dart';
import '../../../infrastructure/services/image_precache_service.dart';
import '../../../infrastructure/services/app_startup_service.dart';

class DiscoveryViewModel extends ChangeNotifier {
  List<UserRecommendationModel> _recommendations = [];
  List<InterestModel> _interests = [];
  final RewindService? _rewindService;
  int _currentProfileIndex = 0;
  final List<UserRecommendationModel> _rejectedProfiles = [];
  bool _isLoading = false;
  bool _isPrecacheDone = false;
  bool get isPrecacheDone => _isPrecacheDone;
  String? _error;
  BuildContext? _context;

  // Current user location for distance calculation
  double? _currentUserLatitude;
  double? _currentUserLongitude;

  // Current user ID to filter out own profile
  int? _currentUserId;

  // Current user avatar
  String? _currentUserAvatarUrl;

  // Service layer for API operations
  final MatchService _matchService;
  final ProfileService _profileService;

  DiscoveryViewModel({
    RewindService? rewindService,
    MatchService? matchService,
    ProfileService? profileService,
  }) : _rewindService = rewindService,
       _matchService = matchService ?? MatchService(),
       _profileService = profileService ?? ProfileService();

  List<UserRecommendationModel> get recommendations => _recommendations;
  List<InterestModel> get interests => _interests;
  UserRecommendationModel? get currentProfile =>
      _recommendations.isNotEmpty &&
              _currentProfileIndex < _recommendations.length
          ? _recommendations[_currentProfileIndex]
          : null;
  bool get hasMoreProfiles =>
      _currentProfileIndex < _recommendations.length - 1;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentProfileIndex => _currentProfileIndex;

  /// Get current user's location coordinates
  double? get currentUserLatitude => _currentUserLatitude;
  double? get currentUserLongitude => _currentUserLongitude;

  /// Get current user ID
  int? get currentUserId => _currentUserId;

  /// Get current user avatar URL
  String? get currentUserAvatarUrl => _currentUserAvatarUrl;

  /// Set context for showing dialogs
  void setContext(BuildContext? context) {
    _context = context;
  }

  /// Load current user's profile to get location information
  Future<void> loadCurrentUserProfile() async {
    try {
      if (AppStartupService.instance.isReady) {
        _currentUserId = AppInitializationService.instance.currentUserId;
      }
      final profileData = await _profileService.getProfile();
      if (_currentUserId == null && profileData['userId'] != null) {
        _currentUserId = profileData['userId'] as int;
        RecommendationCache.instance.setCurrentUserId(_currentUserId);
      }
      if (profileData['avatarUrl'] != null) {
        _currentUserAvatarUrl = profileData['avatarUrl'] as String;
      }
      if (profileData['location'] != null && profileData['location'] is Map<String, dynamic>) {
        final location = profileData['location'] as Map<String, dynamic>;
        final lat = location['latitude'];
        final lon = location['longitude'];
        if (lat != null && lat is num && lat != 0.0) {
          _currentUserLatitude = lat.toDouble();
        }
        if (lon != null && lon is num && lon != 0.0) {
          _currentUserLongitude = lon.toDouble();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Calculate distance between current user and a profile (localized)
  String getDistanceToProfile(UserRecommendationModel profile) {
    if (_context == null) return '';
    final tr = AppLocalizations.of(_context!).translate;
    return DistanceCalculator.getDistanceText(
      _currentUserLatitude,
      _currentUserLongitude,
      profile.latitude,
      profile.longitude,
      tr: tr,
    );
  }

  /// Load recommendations from API
  /// This method fetches user recommendations from the backend API
  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    _isLoading = true;
    _isPrecacheDone = false;
    _error = null;
    notifyListeners();
    
    try {
      await loadCurrentUserProfile();
      
      if (forceRefresh) {
        RecommendationCache.instance.clear();
        AppStartupService.instance.reset();
        ImagePrecacheService.instance.clearCache();
      }
      
      if (AppStartupService.instance.isReady && !forceRefresh) {
        final cached = RecommendationCache.instance.recommendations;
        _recommendations = cached != null ? _filterOutCurrentUser(cached) : [];
        _currentProfileIndex = 0;
        _isLoading = false;
        notifyListeners();
        
        // Precache ngay cả khi dùng cache
        await _precacheInitialImages();
        _isPrecacheDone = true;
        notifyListeners();
        return;
      }
      
      final recommendations = await _matchService.getRecommendations();
      _recommendations = _filterOutCurrentUser(recommendations);
      _currentProfileIndex = 0;
      _isLoading = false;
      notifyListeners();
      RecommendationCache.instance.setRecommendations(_recommendations);
      
      // Precache thông minh
      await _precacheInitialImages();
      _isPrecacheDone = true;
      _isLoading = false;
      notifyListeners();
    } catch (e, stack) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter out current user's profile from recommendations
  List<UserRecommendationModel> _filterOutCurrentUser(
    List<UserRecommendationModel> recommendations,
  ) {
    if (_currentUserId == null) {
      return recommendations;
    }

    final filtered =
        recommendations
            .where((profile) => profile.userId != _currentUserId)
            .toList();

    return filtered;
  }

  void setInterests(List<InterestModel> interests) {
    _interests = interests;
    notifyListeners();
  }

  /// Like current profile
  /// This method handles the like action and checks for potential matches
  Future<void> likeCurrentProfile() async {
    if (_currentProfileIndex >= _recommendations.length) return;

    final currentProfile = _recommendations[_currentProfileIndex];

    try {
      // Call the service layer to like the user
      final response = await _matchService.likeUser(currentProfile.userId);

      // Handle match if occurred
      if (response.isMatch) {
        _handleMatch(response, currentProfile);
      }

      _moveToNextProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Dislike current profile
  /// This method handles the dislike action and stores rejected profiles for rewind
  Future<void> dislikeCurrentProfile() async {
    if (_currentProfileIndex >= _recommendations.length) return;

    final currentProfile = _recommendations[_currentProfileIndex];

    try {
      // Call the service layer to dislike the user
      await _matchService.dislikeUser(currentProfile.userId);

      // Store the rejected profile for potential rewind
      _rejectedProfiles.add(currentProfile);

      // If rewind service is available, add to rewindable users
      if (_rewindService != null) {
        final likedUser = _convertToLikedUserModel(currentProfile);
        _rewindService.addToRewindable(likedUser);
      }

      _moveToNextProfile();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Rewind last profile (VIP feature)
  /// This method allows users to go back to the last rejected profile
  void rewindLastProfile() {
    if (_rewindService != null && _rejectedProfiles.isNotEmpty) {
      final lastRejected = _rejectedProfiles.removeLast();

      // Insert the rewound profile before the current profile
      _recommendations.insert(_currentProfileIndex, lastRejected);

      // Notify that profiles have changed
      notifyListeners();
    }
  }

  /// Move to the next profile in the stack
  void _moveToNextProfile() {
    if (_currentProfileIndex < _recommendations.length) {
      // Clear cache cho profile đã vuốt qua
      if (_currentProfileIndex < _recommendations.length) {
        final swipedProfile = _recommendations[_currentProfileIndex];
        ImagePrecacheService.instance.removeProfileFromCache(swipedProfile.userId);
      }
      
      _currentProfileIndex++;
      
      // Load thêm batch mới nếu cần
      if (_recommendations.length - _currentProfileIndex <= 3) {
        _loadMoreProfilesIfNeeded();
      }
      
      notifyListeners();
      
      // Precache cho profile tiếp theo
      _precacheNextImageOnSwipe();
      _precacheNextBatchIfNeeded();
    }
  }

  /// Tự động load thêm profile mới nếu cần
  Future<void> _loadMoreProfilesIfNeeded() async {
    try {
      final newProfiles = await _matchService.getRecommendations();
      if (newProfiles.isNotEmpty) {
        final filtered = _filterOutCurrentUser(newProfiles);
        final existingIds = _recommendations.map((e) => e.userId).toSet();
        final uniqueNew = filtered.where((e) => !existingIds.contains(e.userId)).toList();
        
        if (uniqueNew.isNotEmpty) {
          _recommendations.addAll(uniqueNew);
          RecommendationCache.instance.setRecommendations(_recommendations);
          
          if (_context != null) {
            await ImagePrecacheService.instance.precacheMultipleProfiles(uniqueNew, _context!, count: uniqueNew.length);
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  /// Handle match response
  /// This method shows the match dialog when a match occurs
  void _handleMatch(
    SwipeResponseModel response,
    UserRecommendationModel matchedProfile,
  ) {
    if (_context != null) {
      showMatchDialog(
        _context!,
        response,
        matchedProfile,
        _currentUserAvatarUrl,
        onStartChat: () {
          // Sử dụng chatRoomId từ backend response thay vì matchId
          final chatId = response.chatRoomId?.toString();

          if (chatId == null || chatId.isEmpty) {
            return;
          }

          Navigator.pushNamed(
            _context!,
            AppRoutes.chatConversation,
            arguments: {
              'chatId': chatId,
              'recipientName': matchedProfile.fullName,
              'recipientAvatar':
                  matchedProfile.photos.isNotEmpty
                      ? UrlTransformer.transform(
                        matchedProfile.photos.first.url,
                      )
                      : null,
              'isOnline': false, // TODO: Check actual online status
            },
          );
        },
      );
    }
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Convert UserRecommendationModel to LikedUserModel for rewind service
  /// This helper method ensures compatibility with the rewind service
  LikedUserModel _convertToLikedUserModel(UserRecommendationModel profile) {
    return LikedUserModel(
      id: profile.userId.toString(),
      firstName: profile.firstName,
      lastName: profile.lastName,
      username: profile.username,
      age: profile.age ?? 0,
      location: profile.location ?? 'Unknown',
      coverImageUrl:
          profile.photos.isNotEmpty
              ? profile.photos.first.displayUrl
              : '',
      avatarUrl:
          profile.photos.isNotEmpty
              ? profile.photos.first.displayUrl
              : '',
      bio: profile.bio ?? '',
      photoUrls:
          profile.photos.map((p) => p.displayUrl).toList(),
      isVip: false,
    );
  }

  // --- Image Pre-caching Logic ---

  /// Pre-caches images for the first few profiles to ensure a smooth initial experience.
  Future<void> _precacheInitialImages() async {
    if (_context == null || _recommendations.isEmpty) return;
    
    // Precache thông minh cho 5 profile đầu tiên
    final profilesToPrecache = _recommendations.take(5).toList();
    await ImagePrecacheService.instance.precacheMultipleProfiles(profilesToPrecache, _context!, count: 5);
  }

  /// Pre-caches images for the profile that will be shown after the next one.
  void _precacheNextImageOnSwipe() {
    final indexToPrecache = _currentProfileIndex + 1;
    if (indexToPrecache < _recommendations.length && _context != null) {
      final profile = _recommendations[indexToPrecache];
      if (!ImagePrecacheService.instance.isProfilePrecached(profile)) {
        ImagePrecacheService.instance.precacheProfileImages(profile, _context!);
      }
    }
  }

  /// Precache batch tiếp theo nếu cần thiết
  void _precacheNextBatchIfNeeded() {
    if (_context == null || _recommendations.isEmpty) return;
    
    // Nếu user đã vuốt qua 2 profile và còn ít hơn 3 profile được precache, thì precache thêm
    if (_currentProfileIndex >= 2 && _currentProfileIndex < _recommendations.length - 3) {
      ImagePrecacheService.instance.precacheNextBatch(_recommendations, _currentProfileIndex, _context!);
    }
  }

  /// Helper method to pre-cache all images for a given profile index.
  void _precacheImagesForProfile(int profileIndex) {
    if (_context == null || profileIndex >= _recommendations.length) return;

    final profile = _recommendations[profileIndex];
    if (profile.photos.isNotEmpty) {
      for (final photo in profile.photos) {
        // Sử dụng cacheUrl thay vì transform để đảm bảo consistency
        final provider = CachedNetworkImageProvider(photo.cacheUrl);
        precacheImage(provider, _context!);
      }
    }
  }
}