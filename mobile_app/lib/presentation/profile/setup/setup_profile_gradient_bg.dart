// lib/presentation/profile/setup/setup_profile_gradient_bg.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/theme/profile_theme.dart';
import 'setup_profile_viewmodel.dart';

class SetupProfileGradientBg extends StatelessWidget {
  final Widget child;

  const SetupProfileGradientBg({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SetupProfileViewModel>(context);
    final decoration = SetupProfileTheme.getGradientDecoration(vm.currentStep, vm.totalSteps);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: decoration,
      child: child,
    );
  }
}
