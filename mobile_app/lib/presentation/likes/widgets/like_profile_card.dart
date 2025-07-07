import 'package:flutter/material.dart';
import '../likes_viewmodel.dart';

class LikeProfileCard extends StatelessWidget {
  final UserProfile profile;
  final bool isBlurred;

  const LikeProfileCard({
    Key? key,
    required this.profile,
    this.isBlurred = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1, red: 0, green: 0, blue: 0),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(profile.coverPhotoUrl),
                  fit: BoxFit.cover,
                  // Apply blur effect if needed
                  colorFilter: isBlurred
                      ? ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.5, red: 0, green: 0, blue: 0),
                          BlendMode.darken,
                        )
                      : null,
                ),
              ),
            ),

            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7, red: 0, green: 0, blue: 0),
                  ],
                ),
              ),
            ),

            // Profile info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Name and age
                  Text(
                    '${profile.firstName}, ${profile.age}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // City
                  Text(
                    profile.city,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9, red: 1, green: 1, blue: 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Blur overlay for VIP-gated content
            if (isBlurred)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1, red: 1, green: 1, blue: 1),
                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white.withValues(alpha: 0.7, red: 1, green: 1, blue: 1),
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
