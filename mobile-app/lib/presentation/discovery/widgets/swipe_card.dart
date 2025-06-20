// lib/presentation/discovery/widgets/swipe_card.dart

import 'package:flutter/material.dart';

import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import 'package:amoura/presentation/discovery/widgets/profile_card.dart';

class SwipeCardStack extends StatelessWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;

  const SwipeCardStack({
    super.key,
    required this.profile,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final appBarHeight = kToolbarHeight + media.padding.top + 18;
    final actionButtonsHeight = 126.0;
    final verticalMargin = 20.0;

    final cardHeight = media.size.height - appBarHeight - actionButtonsHeight - verticalMargin;

    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 430),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        height: cardHeight,
        child: ProfileCard(
          profile: profile,
          interests: interests,
        ),
      ),
    );
  }
}