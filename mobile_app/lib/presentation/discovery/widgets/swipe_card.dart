// lib/presentation/discovery/widgets/swipe_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/presentation/discovery/discovery_viewmodel.dart';

import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import 'swipeable_card.dart';

class SwipeCardStack extends StatelessWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final void Function(bool)? onHighlightLike;
  final void Function(bool)? onHighlightPass;

  const SwipeCardStack({
    super.key,
    required this.profile,
    required this.interests,
    this.onHighlightLike,
    this.onHighlightPass,
  });

  @override
  Widget build(BuildContext context) {
    // Get next profile for peeking effect
    final viewModel = Provider.of<DiscoveryViewModel>(context, listen: false);
    final nextProfileIndex = viewModel.currentProfileIndex + 1;
    final nextProfile =
        (nextProfileIndex < viewModel.recommendations.length)
            ? viewModel.recommendations[nextProfileIndex]
            : null;
    final nextInterests = viewModel.interests;

    // Calculate distance for current profile
    final distance = viewModel.getDistanceToProfile(profile);

    // Calculate distance for next profile
    final nextDistance =
        nextProfile != null
            ? viewModel.getDistanceToProfile(nextProfile)
            : null;

    return Align(
      alignment: Alignment.topCenter,
      child: SwipeableCard(
        key: ValueKey('swipeable_${profile.userId}'),
        profile: profile,
        interests: interests,
        distance: distance,
        nextProfile: nextProfile,
        nextInterests: nextInterests,
        nextDistance: nextDistance,
        onLike:
            () =>
                Provider.of<DiscoveryViewModel>(
                  context,
                  listen: false,
                ).likeCurrentProfile(),
        onPass:
            () =>
                Provider.of<DiscoveryViewModel>(
                  context,
                  listen: false,
                ).dislikeCurrentProfile(),
        onHighlightLike: onHighlightLike,
        onHighlightPass: onHighlightPass,
      ),
    );
  }
}
