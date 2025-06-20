// lib/presentation/discovery/discovery_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/utils/url_transformer.dart';
import '../../data/models/profile/interest_model.dart';
import '../../data/models/profile/profile_model.dart';
import '../../data/models/match/user_recommendation_model.dart';
import '../../data/models/match/swipe_response_model.dart';
import '../../domain/models/match/liked_user_model.dart';
import '../../core/services/match_service.dart';
import '../../infrastructure/services/rewind_service.dart';
import '../discovery/widgets/match_dialog.dart';

class DiscoveryViewModel extends ChangeNotifier {
  List<UserRecommendationModel> _recommendations = [];
  List<InterestModel> _interests = [];
  final RewindService? _rewindService;
  int _currentProfileIndex = 0;
  final List<UserRecommendationModel> _rejectedProfiles = [];
  bool _isLoading = false;
  String? _error;
  BuildContext? _context;

  // Service layer for API operations
  final MatchService _matchService;

  DiscoveryViewModel({
    RewindService? rewindService,
    MatchService? matchService,
  }) : _rewindService = rewindService,
       _matchService = matchService ?? MatchService();

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

  /// Set context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Load recommendations from API
  /// This method fetches user recommendations from the backend API
  Future<void> loadRecommendations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call the service layer to get recommendations
      final recommendations = await _matchService.getRecommendations();
      _recommendations = recommendations;
      _currentProfileIndex = 0;
      _isLoading = false;
      notifyListeners();

      // After loading, pre-cache images for a smoother experience
      _precacheInitialImages();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
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
        _handleMatch(response);
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
  void _handleMatch(SwipeResponseModel response) {
    if (_context != null) {
      showMatchDialog(_context!, response);
    }
    
    // Log the match for debugging
    print('Match occurred! Match ID: ${response.matchId ?? 'N/A'}');
    print('Matched with: ${response.matchedUsername ?? 'Unknown'}');
    print('Message: ${response.matchMessage ?? 'No message'}');
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