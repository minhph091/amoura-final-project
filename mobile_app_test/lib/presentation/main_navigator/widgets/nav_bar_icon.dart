import 'package:flutter/material.dart';
import 'custom_nav_icon.dart';

class NavBarIcon extends StatelessWidget {
  final IconData? icon;
  final String? customIconPath;
  final bool isActive;
  final Color activeColor;
  final double size;

  const NavBarIcon({
    super.key,
    this.icon,
    this.customIconPath,
    required this.isActive,
    required this.activeColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (customIconPath != null) {
      return CustomNavIcon(
        assetPath: customIconPath!,
        isActive: isActive,
        activeColor: activeColor,
        size: size,
      );
    }

    return Container(
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
        child: Icon(
          icon,
          size: size,
          color: isActive ? activeColor : Colors.grey.shade500,
        ),
      ),
    );
  }
}
