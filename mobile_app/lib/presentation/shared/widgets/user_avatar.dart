// lib/presentation/shared/widgets/user_avatar.dart

import 'package:flutter/material.dart';
import '../../../core/constants/asset_path.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isVip;
  final double radius;
  final bool showFrame;
  final Color? frameColor;
  final double frameWidth;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.isVip = false,
    this.radius = 32,
    this.showFrame = true,
    this.frameColor,
    this.frameWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = frameColor ??
        (isVip ? Colors.amber.shade700 : Colors.transparent);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showFrame
                ? Border.all(color: borderColor, width: frameWidth)
                : null,
            boxShadow: [
              if (isVip)
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : const AssetImage(AssetPath.defaultAvatar) as ImageProvider,
          ),
        ),
        if (isVip)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.shade100,
                    blurRadius: 6,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.star, color: Colors.white, size: 16),
            ),
          ),
      ],
    );
  }
}
