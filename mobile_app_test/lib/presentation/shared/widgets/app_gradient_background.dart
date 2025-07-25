// lib/presentation/shared/widgets/app_gradient_background.dart
import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ??
            (isDark
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF22223B),
                Color(0xFF364F6B),
              ],
            )
                : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFEAF4),
                Color(0xFFE4FFFA),
                Color(0xFFFFF0F5),
              ],
            )),
      ),
      child: child,
    );
  }
}
