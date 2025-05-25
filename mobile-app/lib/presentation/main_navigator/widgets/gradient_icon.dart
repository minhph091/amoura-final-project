// lib/presentation/main_navigator/widgets/gradient_icon_3d.dart
// Gradient and 3D-style icon widget for navigation or action buttons.

import 'package:flutter/material.dart';

class GradientIcon3D extends StatelessWidget {
  final IconData icon;
  final double size;
  final Gradient gradient;
  final bool withShadow;
  final double elevation;

  const GradientIcon3D({
    super.key,
    required this.icon,
    required this.size,
    required this.gradient,
    this.withShadow = true,
    this.elevation = 7.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: withShadow ? elevation : 0.0,
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => gradient.createShader(bounds),
        child: Icon(icon, size: size),
      ),
    );
  }
}