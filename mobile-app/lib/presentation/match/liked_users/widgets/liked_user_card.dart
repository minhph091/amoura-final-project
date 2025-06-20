import 'package:flutter/material.dart';
import '../../../../domain/models/match/liked_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../discovery/widgets/match_dialog.dart';
import '../../../../data/models/match/swipe_response_model.dart';
import '../../../../core/utils/url_transformer.dart';

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
            color: Colors.black.withOpacity(0.1),
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
              child: Positioned.fill(
                child: _buildCoverImage(),
              ),
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
                      Colors.black.withOpacity(0.7),
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
            Positioned(
              top: 10,
              right: 10,
              child: _buildLikeButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Create a mock SwipeResponseModel for the match dialog
        // In a real scenario, this would come from the API response
        final mockMatchResponse = SwipeResponseModel(
          swipeId: 0, // Mock swipe ID
          isMatch: true,
          matchId: 0, // Mock match ID
          matchedUserId: int.tryParse(user.id) ?? 0,
          matchedUsername: user.firstName,
          matchMessage: 'It\'s a match with ${user.firstName}!',
        );
        
        // Show match dialog when user likes back
        showMatchDialog(context, mockMatchResponse).then((_) {
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
              color: Colors.pink.withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (user.coverImageUrl.startsWith('http')) {
      final transformedUrl = UrlTransformer.transform(user.coverImageUrl);
      return CachedNetworkImage(
        imageUrl: transformedUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
          ),
        ),
      );
    } else {
      // Handle local assets or placeholder
      return Image.asset(
        'assets/images/avatars/placeholder.jpg',
        fit: BoxFit.cover,
      );
    }
  }
}
