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
    final age = profile.age ?? (profile.dateOfBirth != null
        ? DateUtil.calculateAge(profile.dateOfBirth!)
        : 0);
    final location = profile.location ?? 'Unknown';
    final bio = profile.bio ?? 'No bio provided';
    final name = profile.fullName;
    
    // Use profile's interests if available, otherwise fall back to passed interests
    final profileInterests = profile.interests.isNotEmpty ? profile.interests : interests;
    
    final interestChips = profileInterests
        .map((interest) {
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
    })
        .toList();

    // --- Filter and sort photos: cover first, then up to 4 highlights by uploadedAt ---
    final coverList = profile.photos.where((p) => p.type == 'profile_cover').toList();
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

    return Stack(
      children: [
        // Main image carousel with story progress bar
        ImageCarousel(
          key: ValueKey(profile.userId),
          photos: displayPhotos,
          showStoryProgress: true,
          controller: imageController,
        ),
        // Overlay user info at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.45),
                  Colors.black.withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$age',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (distance != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    distance!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 13),
                Text(
                  bio,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 17),
                Wrap(
                  spacing: 0,
                  runSpacing: 0,
                  children: interestChips
                      .map<Widget>((interest) => InterestChip(
                            label: interest.label,
                            icon: interest.icon,
                            iconColor: interest.iconColor,
                            borderColor: interest.borderColor,
                            gradient: interest.gradient,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}