// lib/presentation/discovery/widgets/profile_card.dart
// Discovery profile card, correct vertical layout and scroll.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/profile/interest_model.dart';
import '../../../data/models/match/user_recommendation_model.dart';
import '../../../core/utils/date_util.dart';
import '../../../core/services/profile_service.dart';
import '../../../app/di/injection.dart';
import 'image_carousel.dart';
import 'profile_detail_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../profile/view/profile_viewmodel.dart';
import '../../../config/language/app_localizations.dart';

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

  /// Tìm common interests giữa current user và recommendation user
  Future<List<String>> _getCommonInterests() async {
    try {
      final profileService = getIt<ProfileService>();
      final currentUserProfile = await profileService.getProfile();

      // Extract current user interests
      final currentUserInterests = <String>[];
      if (currentUserProfile['interests'] != null) {
        final interestsList = currentUserProfile['interests'] as List;
        currentUserInterests.addAll(
          interestsList.map((i) => i['name'].toString().toLowerCase()).toList(),
        );
      }

      // Extract recommendation user interests
      final recommendationInterests =
          profile.interests.map((i) => i.name.toLowerCase()).toList();

      // Find common interests (max 3)
      final commonInterests =
          currentUserInterests
              .where((interest) => recommendationInterests.contains(interest))
              .take(3)
              .toList();

      return commonInterests;
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageText =
        profile.age != null
            ? ', ${profile.age}'
            : (profile.dateOfBirth != null
                ? ', ${DateUtil.calculateAge(profile.dateOfBirth!)}'
                : '');
    final displayLocation = distance ?? profile.location ?? 'Unknown';
    final bio =
        profile.bio?.isNotEmpty == true
            ? profile.bio!
            : 'Always ready for an adventure!';
    final name = profile.fullName;

    // --- Filter and sort photos: cover first, then up to 4 highlights by uploadedAt ---
    final coverList =
        profile.photos.where((p) => p.type == 'profile_cover').toList();
    final cover = coverList.isNotEmpty ? coverList.first : null;
    final highlights =
        profile.photos.where((p) => p.type == 'highlight').toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final displayPhotos = [if (cover != null) cover, ...highlights.take(4)];

    // Controller for resetting image index
    final ImageCarouselController imageController = ImageCarouselController();
    // Có thể truyền cacheManager tùy chỉnh nếu muốn (ví dụ: DefaultCacheManager())
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Main image carousel with story progress bar
          ImageCarousel(
            key: ValueKey('profile_card_${profile.userId}_${profile.photos.map((p) => p.url).join()}'),
            photos: displayPhotos,
            showStoryProgress: true,
            controller: imageController,
            uniqueKey: 'profile_${profile.userId}_${profile.photos.map((p) => p.url).join()}',
            cacheManager: null, // Truyền cacheManager nếu có
          ),
          // Overlay user info at the bottom with backdrop blur
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '$name$ageText',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: () async {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: getIt<ProfileService>().getProfileByUserId(profile.userId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      final profileData = snapshot.data;
                                      if (profileData == null) {
                                        // Fallback: dùng dữ liệu cũ nếu lỗi
                                        return ProfileDetailBottomSheet(
                                          profile: {
                                            'bio': profile.bio ?? '-',
                                            'height': profile.height != null ? profile.height.toString() : '-',
                                            'sex': profile.sex ?? '-',
                                            'location': profile.location != null ? {'city': profile.location} : null,
                                            'interests': interests.map((e) => {'name': e.name}).toList(),
                                            'pets': profile.pets.map((e) => {'name': e.name}).toList(),
                                            'orientation': null,
                                            'jobIndustry': null,
                                            'educationLevel': null,
                                            'languages': [],
                                            'drinkStatus': null,
                                            'smokeStatus': null,
                                          },
                                          distance: distance,
                                        );
                                      }
                                      return ProfileDetailBottomSheet(
                                        profile: profileData,
                                        distance: distance,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            tooltip: 'Xem thông tin chi tiết',
                          ),
                        ],
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
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
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Common interests section
                      FutureBuilder<List<String>>(
                        future: _getCommonInterests(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).translate('common_interests'),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children:
                                      snapshot.data!.map((interest) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.red.withOpacity(
                                                  0.8,
                                                ),
                                                Colors.pink.withOpacity(
                                                  0.8,
                                                ),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.red.withOpacity(
                                                0.6,
                                              ),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.red.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            interest,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              shadows: [
                                                const Shadow(
                                                  color: Colors.black,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      // Add padding at the bottom to push content up
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
