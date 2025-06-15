import 'package:flutter/material.dart';
import '../../../../domain/models/match/liked_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LikedUserCard extends StatelessWidget {
  final LikedUserModel user;
  final VoidCallback onTap;

  const LikedUserCard({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              // Cover image
              Positioned.fill(
                child: _buildCoverImage(),
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

              // VIP badge if applicable
              if (user.isVip == true)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          color: Colors.white,
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Info icon button
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: onTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (user.coverImageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: user.coverImageUrl,
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

