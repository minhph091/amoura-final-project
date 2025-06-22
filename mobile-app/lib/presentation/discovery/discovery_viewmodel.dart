// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/url_transformer.dart';
import '../../core/utils/distance_calculator.dart';
import '../../data/models/profile/interest_model.dart';
import '../../data/models/profile/profile_model.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/match/swipe_response_model.dart';
import '../../domain/models/match/liked_user_model.dart';
import '../../core/services/match_service.dart';
import '../../core/services/profile_service.dart';
import '../../infrastructure/services/rewind_service.dart';
import '../discovery/widgets/match_dialog.dart';
import 'discovery_recommendation_cache.dart';

class DiscoveryViewModel extends ChangeNotifier {
  List<UserRecommendationModel> _recommendations = [];
  List<InterestModel> _interests = [];
  final RewindService? _rewindService;
  int _currentProfileIndex = 0;
  final List<UserRecommendationModel> _rejectedProfiles = [];
  bool _isLoading = false;
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
      _recommendations.isNotEmpty && _currentProfileIndex < _recommendations.length
          ? _recommendations[_currentProfileIndex]
          : null;
  bool get hasMoreProfiles => _currentProfileIndex < _recommendations.length - 1;
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
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Load current user's profile to get location information
  Future<void> loadCurrentUserProfile() async {
    try {
      final profileData = await _profileService.getProfile();
      
      // Extract current user ID
      if (profileData['userId'] != null) {
        _currentUserId = profileData['userId'] as int;
        // Set current user ID in cache for filtering
        RecommendationCache.instance.setCurrentUserId(_currentUserId);
      }
      
      // Extract current user avatar
      if (profileData['avatarUrl'] != null) {
        _currentUserAvatarUrl = profileData['avatarUrl'] as String;
      }
      
      // Extract location data from profile
      if (profileData['location'] != null && profileData['location'] is Map<String, dynamic>) {
        final location = profileData['location'] as Map<String, dynamic>;
        
        // Handle both null and 0.0 values (backend might return 0.0 instead of null)
        final lat = location['latitude'];
        final lon = location['longitude'];
        
        if (lat != null && lat is num && lat != 0.0) {
          _currentUserLatitude = lat.toDouble();
        }
        
        if (lon != null && lon is num && lon != 0.0) {
          _currentUserLongitude = lon.toDouble();
        }
        
        print('Current user location extracted: $_currentUserLatitude, $_currentUserLongitude');
      } else {
        print('No location data found in profile response');
        print('Profile data keys: ${profileData.keys.toList()}');
        if (profileData['location'] != null) {
          print('Location data type: ${profileData['location'].runtimeType}');
          print('Location data: ${profileData['location']}');
        }
      }
    } catch (e) {
      print('Error loading current user profile: $e');
      // Don't throw error, just log it - distance calculation will show "Distance unavailable"
    }
  }

  /// Calculate distance between current user and a profile
  String getDistanceToProfile(UserRecommendationModel profile) {
    final distance = DistanceCalculator.getDistanceText(
      _currentUserLatitude,
      _currentUserLongitude,
      profile.latitude,
      profile.longitude,
    );
    
    return distance;
  }

  /// Load recommendations from API
  /// This method fetches user recommendations from the backend API
  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load current user profile first to get location for distance calculation
      await loadCurrentUserProfile();
      
      // If forceRefresh, clear cache before calling API
      if (forceRefresh) {
        RecommendationCache.instance.clear();
      }
      // Check cache first
      final cached = RecommendationCache.instance.recommendations;
      if (!forceRefresh && cached != null && cached.isNotEmpty) {
        _recommendations = _filterOutCurrentUser(cached);
        _currentProfileIndex = 0;
        _isLoading = false;
        notifyListeners();
        _precacheInitialImages();
        return;
      }
      // Call the service layer to get recommendations
      final recommendations = await _matchService.getRecommendations();
      _recommendations = _filterOutCurrentUser(recommendations);
      _currentProfileIndex = 0;
      _isLoading = false;
      notifyListeners();
      // Cache the new recommendations
      RecommendationCache.instance.setRecommendations(_recommendations);
      // After loading, pre-cache images for a smoother experience
      _precacheInitialImages();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Filter out current user's profile from recommendations
  List<UserRecommendationModel> _filterOutCurrentUser(List<UserRecommendationModel> recommendations) {
    if (_currentUserId == null) {
      return recommendations;
    }
    
    final filtered = recommendations.where((profile) => profile.userId != _currentUserId).toList();
    
    if (filtered.length != recommendations.length) {
      print('Filtered out current user profile (ID: $_currentUserId) from recommendations');
    }
    
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
      _currentProfileIndex++;
      notifyListeners();
      // Pre-cache images for the upcoming profile
      _precacheNextImageOnSwipe();
    }
  }

  /// Handle match response
  /// This method shows the match dialog when a match occurs
  void _handleMatch(SwipeResponseModel response, UserRecommendationModel matchedProfile) {
    if (_context != null) {
      showMatchDialog(_context!, response, matchedProfile, _currentUserAvatarUrl);
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
      coverImageUrl: profile.photos.isNotEmpty ? profile.photos.first.url : 'https://example.com/placeholder.jpg',
      avatarUrl: profile.photos.isNotEmpty ? profile.photos.first.url : 'https://example.com/avatar.jpg',
      bio: profile.bio ?? '',
      photoUrls: profile.photos.map((p) => p.url).toList(),
      isVip: false,
    );
  }

  // --- Image Pre-caching Logic ---

  /// Pre-caches images for the first few profiles to ensure a smooth initial experience.
  void _precacheInitialImages() {
    if (_context == null || _recommendations.length < 1) return;

    // Cache current (index 0) and next (index 1) profiles
    final int endIndex = _recommendations.length > 2 ? 2 : _recommendations.length;
    for (int i = 0; i < endIndex; i++) {
      _precacheImagesForProfile(i);
    }
  }

  /// Pre-caches images for the profile that will be shown after the next one.
  void _precacheNextImageOnSwipe() {
    // When the user swipes and `_currentProfileIndex` is updated,
    // we pre-cache the profile that is now 2 positions away, so it's ready.
    // e.g., if we are now showing index 1, we pre-cache index 2.
    final indexToPrecache = _currentProfileIndex + 1;

    if (indexToPrecache < _recommendations.length) {
      _precacheImagesForProfile(indexToPrecache);
    }
  }

  /// Helper method to pre-cache all images for a given profile index.
  void _precacheImagesForProfile(int profileIndex) {
    if (_context == null || profileIndex >= _recommendations.length) return;

    final profile = _recommendations[profileIndex];
    if (profile.photos.isNotEmpty) {
      for (final photo in profile.photos) {
        final transformedUrl = UrlTransformer.transform(photo.url);
        final provider = CachedNetworkImageProvider(transformedUrl);
        precacheImage(provider, _context!);
      }
    }
  }
}