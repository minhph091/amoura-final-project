import 'package:flutter/material.dart';

class NavBarCircleBurst extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double maxRadius;

  const NavBarCircleBurst({
    super.key,
    required this.animation,
    required this.color,
    this.maxRadius = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = animation.value;
        final opacity = 1.0 - scale.clamp(0, 1);
        return Opacity(
          opacity: opacity,
          child: Center(
            child: Container(
              width: maxRadius * scale,
              height: maxRadius * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: 0.7),
                  width: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}