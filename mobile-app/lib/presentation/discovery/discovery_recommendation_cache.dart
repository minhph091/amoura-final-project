import 'package:amoura/data/models/match/user_recommendation_model.dart';
import 'package:amoura/core/services/match_service.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get_it/get_it.dart';

class RecommendationCache {
  static final RecommendationCache instance = RecommendationCache._internal();
  RecommendationCache._internal();

  List<UserRecommendationModel>? _recommendations;

  List<UserRecommendationModel>? get recommendations => _recommendations;

  void setRecommendations(List<UserRecommendationModel> recs) {
    _recommendations = recs;
  }

  Future<void> preloadRecommendations() async {
    final matchService = GetIt.I<MatchService>();
    final recs = await matchService.getRecommendations();
    _recommendations = recs;
    // Precache images for first 2 profiles
    final context = GetIt.I<GlobalKey<NavigatorState>>().currentContext;
    if (context != null && recs.isNotEmpty) {
      for (int i = 0; i < recs.length && i < 2; i++) {
        for (final photo in recs[i].photos) {
          final provider = CachedNetworkImageProvider(photo.url);
          precacheImage(provider, context);
        }
      }
    }
  }

  Future<void> ensurePrecacheForProfiles(List<UserRecommendationModel> profiles, BuildContext context, {int count = 5}) async {
    for (int i = 0; i < profiles.length && i < count; i++) {
      for (final photo in profiles[i].photos) {
        final provider = CachedNetworkImageProvider(photo.url);
        await precacheImage(provider, context);
      }
    }
  }

  void clear() {
    _recommendations = null;
  }
} 