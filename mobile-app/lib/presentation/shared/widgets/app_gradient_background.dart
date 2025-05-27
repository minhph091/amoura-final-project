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
                Color(0x27FC5185),
                Color(0x3043DDE6),
                Color(0x38E0C3FC),
              ],
            )),
      ),
      child: child,
    );
  }
}