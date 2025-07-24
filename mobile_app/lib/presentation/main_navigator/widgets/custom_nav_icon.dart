import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'glow_effect.dart';

class CustomNavIcon extends StatelessWidget {
  final String assetPath;
  final bool isActive;
  final Color activeColor;
  final double size;

  const CustomNavIcon({
    super.key,
    required this.assetPath,
    required this.isActive,
    required this.activeColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GlowEffect(
      glowColor: activeColor,
      isActive: isActive,
      child: Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient:
              isActive
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withValues(alpha: 0.2),
                      activeColor.withValues(alpha: 0.1),
                    ],
                  )
                  : null,
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: size,
            height: size,
            colorFilter:
                isActive
                    ? null // Giữ màu gốc của SVG khi active
                    : ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
