// lib/presentation/auth/setup_profile/setup_profile_gradient_bg.dart
// Widget to provide a dynamic gradient background for the setup profile screens.

import 'package:flutter/material.dart';
import 'setup_profile_viewmodel.dart';
import 'package:provider/provider.dart';

List<Color> _getGradientForStep(int currentStep, int totalSteps) {
  const pinkStart = Color(0xFFFFE1F0);
  const purpleEnd = Color(0xFFE1D0FF);
  double factor = currentStep / (totalSteps - 1);
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