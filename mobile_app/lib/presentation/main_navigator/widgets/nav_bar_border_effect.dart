import 'package:flutter/material.dart';

class NavBarBorderEffect extends StatelessWidget {
  final bool show;
  final Color color;
  final double size;
  final double borderWidth;

  const NavBarBorderEffect({
    super.key,
    required this.show,
    required this.color,
    this.size = 44,
    this.borderWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();
    return Positioned.fill(
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}