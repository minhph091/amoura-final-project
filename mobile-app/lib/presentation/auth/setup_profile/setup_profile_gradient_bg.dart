// lib/presentation/auth/setup_profile/setup_profile_gradient_bg.dart
// Widget to provide a dynamic gradient background for the setup profile screens.

import 'package:flutter/material.dart';
import 'setup_profile_viewmodel.dart';
import 'package:provider/provider.dart';

// Function to calculate gradient colors based on the current step.
List<Color> _getGradientForStep(int currentStep, int totalSteps) {
  // Base colors for the pink-to-purple gradient, starting light.
  const pinkStart = Color(0xFFFFE1F0); // Light pink
  const purpleEnd = Color(0xFFE1D0FF); // Light purple

  // Calculate interpolation factor based on step progress.
  double factor = currentStep / (totalSteps - 1);

  // Interpolate between start and end colors to make background lighter as steps progress.
  final startColor = Color.lerp(pinkStart, purpleEnd, factor) ?? pinkStart;
  final endColor = Color.lerp(purpleEnd, pinkStart, factor) ?? purpleEnd;

  return [startColor, endColor];
}

class SetupProfileGradientBg extends StatelessWidget {
  final Widget child;

  const SetupProfileGradientBg({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final colors = _getGradientForStep(vm.currentStep, vm.totalSteps);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}