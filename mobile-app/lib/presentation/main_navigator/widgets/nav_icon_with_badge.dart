// lib/presentation/main_navigator/widgets/nav_icon_with_badge.dart

import 'package:flutter/material.dart';
import 'gradient_icon.dart';

class NavIconWithBadge extends StatelessWidget {
  final Widget icon;
  final bool isActive;
  final int? badgeCount;
  final String? vipBadge;

  const NavIconWithBadge({
    super.key,
    required this.icon,
    this.isActive = false,
    this.badgeCount,
    this.vipBadge,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = icon;
    if (badgeCount != null && badgeCount! > 0) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          icon,
          Positioned(
            right: -5, top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Text(
                badgeCount! > 9 ? '9+' : '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      );
    } else if (vipBadge != null) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          icon,
          Positioned(
            right: -8, top: -5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.amber, Colors.deepOrange]),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                vipBadge!,
                style: const TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      );
    }
    return AnimatedScale(
      scale: isActive ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: content,
    );
  }
}