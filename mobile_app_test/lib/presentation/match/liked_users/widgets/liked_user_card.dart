// ignore_for_file: use_build_context_synchronously

import 'package:amoura/app/di/injection.dart';
import 'package:amoura/core/services/profile_service.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/match/liked_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../discovery/widgets/match_dialog.dart';
import '../../../../data/models/match/swipe_response_model.dart';
import '../../../../core/utils/url_transformer.dart';
import '../../../../data/models/match/user_recommendation_model.dart';
import '../../../../data/models/profile/photo_model.dart';

class LikedUserCard extends StatelessWidget {
  final LikedUserModel user;
  final VoidCallback onTap;
  final VoidCallback? onLike;

  const LikedUserCard({
    super.key,
    required this.user,
    required this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Cover image - tappable to view profile
            GestureDetector(
              onTap: onTap,
              child: Positioned.fill(child: _buildCoverImage()),
            ),

            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

            // User info at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.firstName}, ${user.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.location,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Like button in top-right corner
            Positioned(top: 10, right: 10, child: _buildLikeButton(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Create a mock SwipeResponseModel for the match dialog
        // In a real scenario, this would come from the API response
        final mockMatchResponse = SwipeResponseModel(
          swipeId: 0, // Mock swipe ID
          isMatch: true,
          matchId: 0, // Mock match ID
          chatRoomId: 1, // Mock chat room ID để tránh lỗi navigation
          matchedUserId: int.tryParse(user.id) ?? 0,
          matchedUsername: user.firstName,
          matchMessage: 'It\'s a match with ${user.firstName}!',
        );

        final matchedProfile = UserRecommendationModel(
          userId: int.tryParse(user.id) ?? 0,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
          age: user.age,
          bio: user.bio,
          location: user.location,
          photos:
              user.photoUrls
                  .map(
                    (url) => PhotoModel(
                      id: 0, // Mock ID
                      userId: int.tryParse(user.id) ?? 0, // Mock user ID
                      path: url, // Correct parameter name
                      type: 'highlight', // Mock type
                      createdAt: DateTime.now(), // Mock date
                    ),
                  )
                  .toList(),
          interests: [], // Not available in LikedUserModel, provide empty list
          pets: [], // Not available in LikedUserModel, provide empty list
        );
        // Get current user's avatar
        final profileService = getIt<ProfileService>();
        final profileData = await profileService.getProfile();
        final currentUserAvatarUrl = profileData['avatarUrl'] as String?;
        // Show match dialog when user likes back
        showMatchDialog(
          context,
          mockMatchResponse,
          matchedProfile,
          currentUserAvatarUrl,
        ).then((_) {
          // Call the onLike callback if provided
          if (onLike != null) {
            onLike!();
          }
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Colors.pink, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildCoverImage() {
    // Ưu tiên sử dụng avatar, nếu không có thì dùng cover image hoặc photo đầu tiên
    String? imageUrl;

    if (user.avatarUrl.isNotEmpty) {
      imageUrl = user.avatarUrl;
    } else if (user.coverImageUrl.isNotEmpty) {
      imageUrl = user.coverImageUrl;
    } else if (user.photoUrls.isNotEmpty) {
      imageUrl = user.photoUrls.first;
    }

    if (imageUrl != null && imageUrl.startsWith('http')) {
      final transformedUrl = UrlTransformer.transform(imageUrl);
      return CachedNetworkImage(
        imageUrl: transformedUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey, size: 50),
            ),
      );
    } else {
      // Handle placeholder images - use a colorful placeholder for demo
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.primaries[user.id.hashCode % Colors.primaries.length]
                  .withValues(alpha: 0.8),
              Colors.primaries[(user.id.hashCode + 1) % Colors.primaries.length]
                  .withValues(alpha: 0.6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: Text(
                  '${user.firstName[0]}${user.lastName.isNotEmpty ? user.lastName[0] : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user.firstName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
