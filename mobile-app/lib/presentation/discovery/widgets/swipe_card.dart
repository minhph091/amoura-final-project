// lib/presentation/discovery/widgets/swipe_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/presentation/discovery/discovery_viewmodel.dart';

import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import 'package:amoura/presentation/discovery/widgets/profile_card.dart';
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
    final media = MediaQuery.of(context);
    final appBarHeight = kToolbarHeight + media.padding.top + 18;
    final actionButtonsHeight = 126.0;
    final verticalMargin = 20.0;

    final cardHeight = media.size.height - appBarHeight - actionButtonsHeight - verticalMargin;

    // Get next profile for peeking effect
    final nextProfileIndex = Provider.of<DiscoveryViewModel>(context, listen: false).currentProfileIndex + 1;
    final viewModel = Provider.of<DiscoveryViewModel>(context, listen: false);
    final nextProfile = (nextProfileIndex < viewModel.recommendations.length)
        ? viewModel.recommendations[nextProfileIndex]
        : null;
    final nextInterests = viewModel.interests;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: double.infinity,
        height: cardHeight,
        child: SwipeableCard(
          profile: profile,
          interests: interests,
          nextProfile: nextProfile,
          nextInterests: nextInterests,
          onLike: () => Provider.of<DiscoveryViewModel>(context, listen: false).likeCurrentProfile(),
          onPass: () => Provider.of<DiscoveryViewModel>(context, listen: false).dislikeCurrentProfile(),
          onHighlightLike: onHighlightLike,
          onHighlightPass: onHighlightPass,
        ),
      ),
    );
  }
}