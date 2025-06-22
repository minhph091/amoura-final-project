import 'package:amoura/data/models/match/user_recommendation_model.dart';
import 'package:amoura/core/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';
import '../../../core/utils/url_transformer.dart';

class RecommendationCache {
  static final RecommendationCache instance = RecommendationCache._internal();
  RecommendationCache._internal();

  List<UserRecommendationModel>? _recommendations;
  int? _currentUserId;

  List<UserRecommendationModel>? get recommendations => _recommendations;

  void setRecommendations(List<UserRecommendationModel> recs) {
    _recommendations = recs;
  }

  void setCurrentUserId(int? userId) {
    _currentUserId = userId;
  }

  Future<void> preloadRecommendations() async {
    final matchService = GetIt.I<MatchService>();
    final recs = await matchService.getRecommendations();
    _recommendations = _filterOutCurrentUser(recs);
    // Precache images for first 2 profiles
    final context = GetIt.I<GlobalKey<NavigatorState>>().currentContext;
    if (context != null && _recommendations!.isNotEmpty) {
      for (int i = 0; i < _recommendations!.length && i < 2; i++) {
        await _precacheProfileData(_recommendations![i], context);
      }
    }
  }

  Future<void> ensurePrecacheForProfiles(List<UserRecommendationModel> profiles, BuildContext context, {int count = 5}) async {
    for (int i = 0; i < profiles.length && i < count; i++) {
      await _precacheProfileData(profiles[i], context);
    }
  }

  /// Precache all data for a specific profile including images and other resources
  Future<void> _precacheProfileData(UserRecommendationModel profile, BuildContext context) async {
    if (profile.photos.isNotEmpty) {
      for (final photo in profile.photos) {
        final transformedUrl = UrlTransformer.transform(photo.url);
        final provider = CachedNetworkImageProvider(transformedUrl);
        await precacheImage(provider, context);
      }
    }
  }

  /// Filter out current user's profile from recommendations
  List<UserRecommendationModel> _filterOutCurrentUser(List<UserRecommendationModel> recommendations) {
    if (_currentUserId == null) {
      return recommendations;
    }
    
    return recommendations.where((profile) => profile.userId != _currentUserId).toList();
  }

  void clear() {
    _recommendations = null;
    _currentUserId = null;
  }
} 