import 'package:flutter/material.dart';

// A container with a gradient background.
// Simplifies using gradients across the app with consistent styling.
class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GradientContainer({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? _defaultGradient(context),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  // Default gradient to use when none is provided
  LinearGradient _defaultGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ]
          : [
              Colors.white,
              const Color(0xFFF5F6FA),
            ],
    );
  }
}
