// lib/presentation/settings/widgets/settings_header.dart
import 'package:flutter/material.dart';
import '../../profile/view/profile_view.dart';

class SettingsHeader extends StatelessWidget {
  final String avatarUrl;
  final String firstName;
  final String lastName;
  final String username;
  final bool isVip;

  const SettingsHeader({
    super.key,
    required this.avatarUrl,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.isVip,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = '$firstName $lastName';
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Chuyển sang form View Profile
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ProfileView(
            isMyProfile: true, // Set this according to your logic
          )),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // VIP border gradient
                if (isVip)
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(
                        colors: [
                          Color(0xFFE91E63),
                          Color(0xFFFFEB3B),
                          Color(0xFFF44336),
                          Color(0xFF9C27B0),
                          Color(0xFFE91E63),
                        ],
                        stops: [0.0, 0.35, 0.6, 0.85, 1.0],
                      ),
                    ),
                  ),
                // Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    border: isVip
                        ? Border.all(color: Colors.transparent, width: 3)
                        : null,
                  ),
                  child: ClipOval(
                    child: avatarUrl.isEmpty
                        ? Icon(Icons.person, size: 52, color: theme.disabledColor)
                        : Image.network(avatarUrl, fit: BoxFit.cover),
                  ),
                ),
                // Chữ VIP
                if (isVip)
                  Positioned(
                    bottom: 2,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFF69B4)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 11,
                            shadows: [Shadow(color: Colors.black26, blurRadius: 2)]
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên nổi bật cho VIP
                  Row(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isVip
                                    ? const Color(0xFFFFD700)
                                    : theme.textTheme.bodyLarge?.color,
                                shadows: isVip
                                    ? [
                                  const Shadow(
                                    color: Colors.amberAccent,
                                    blurRadius: 8,
                                  )
                                ]
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isVip)
                        const SizedBox(width: 6),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Username dưới tên
                  Text(
                    '@$username',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha:0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Mũi tên
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha:0.6),
            ),
          ],
        ),
      ),
    );
  }
}