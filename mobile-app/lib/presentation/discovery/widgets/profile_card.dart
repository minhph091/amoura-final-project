// lib/presentation/discovery/widgets/profile_card.dart
// Discovery profile card, correct vertical layout and scroll.

import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../core/constants/profile/interest_constants.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/utils/distance_calculator.dart';
import 'image_carousel.dart';
import 'user_info_section.dart';
import 'interest_chip.dart';

class ProfileCard extends StatelessWidget {
  final UserRecommendationModel profile;
  final List<InterestModel> interests;
  final String? distance;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.interests,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final ageText = profile.age != null
        ? ', ${profile.age}'
        : (profile.dateOfBirth != null
            ? ', ${DateUtil.calculateAge(profile.dateOfBirth!)}'
            : '');
    final displayLocation = distance ?? profile.location ?? 'Unknown';
    final bio =
        profile.bio?.isNotEmpty == true ? profile.bio! : 'Always ready for an adventure!';
    final name = profile.fullName;

    // Use profile's interests if available, otherwise fall back to passed interests
    final profileInterests =
        profile.interests.isNotEmpty ? profile.interests : interests;

    final interestChips = profileInterests.map((interest) {
      final interestOption = interestOptions.firstWhere(
        (option) => option['value'] == interest.name,
        orElse: () => {
          'label': interest.name,
          'icon': Icons.interests,
          'color': Colors.grey,
        },
      );
      return InterestChipData(
        label: interestOption['label'],
        icon: interestOption['icon'],
        iconColor: interestOption['color'],
        borderColor: interestOption['color'],
        gradient: LinearGradient(
          colors: [
            interestOption['color'].withValues(alpha: 0.1),
            interestOption['color'].withValues(alpha: 0.1),
          ],
        ),
      );
    }).toList();

    // --- Filter and sort photos: cover first, then up to 4 highlights by uploadedAt ---
    final coverList =
        profile.photos.where((p) => p.type == 'profile_cover').toList();
    final cover = coverList.isNotEmpty ? coverList.first : null;
    final highlights = profile.photos
        .where((p) => p.type == 'highlight')
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final displayPhotos = [
      if (cover != null) cover,
      ...highlights.take(4),
    ];

    // Controller for resetting image index
    final ImageCarouselController imageController = ImageCarouselController();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // Main image carousel with story progress bar
          ImageCarousel(
            key: ValueKey(profile.userId),
            photos: displayPhotos,
            showStoryProgress: true,
            controller: imageController,
            uniqueKey: 'profile_${profile.userId}', // Add unique key to prevent flickering
          ),
          // Overlay user info at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$name$ageText',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayLocation,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      bio,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (interestChips.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: interestChips
                          .map<Widget>((interest) => InterestChip(
                                label: interest.label,
                                icon: interest.icon,
                                iconColor: interest.iconColor,
                              ))
                          .toList(),
                    ),
                  // Add padding at the bottom to push content up
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}