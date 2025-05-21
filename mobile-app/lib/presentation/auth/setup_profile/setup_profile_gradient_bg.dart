// lib/presentation/auth/setup_profile/setup_profile_gradient_bg.dart

import 'package:flutter/material.dart';

class SetupProfileGradientBg extends StatelessWidget {
  final Widget child;

  const SetupProfileGradientBg({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xffF7B0EC), Color(0xffC2E9FB), Color(0xffF7F0FA)], // Gradient colors for background
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}