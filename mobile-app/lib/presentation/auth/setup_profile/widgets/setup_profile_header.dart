// lib/presentation/auth/setup_profile/widgets/setup_profile_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/setup_profile_theme.dart';

class SetupProfileHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool showSkip;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const SetupProfileHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.showSkip,
    this.onBack,
    this.onSkip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center title and step indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Setup Profile',
                style: SetupProfileTheme.getTitleStyle(context),
                textAlign: TextAlign.center,
              ),
              Text(
                '($currentStep/$totalSteps)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: SetupProfileTheme.darkPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Position buttons on sides
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              onBack != null
                  ? TextButton(
                onPressed: onBack,
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: SetupProfileTheme.darkPink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(
                duration: const Duration(milliseconds: 800),
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              )
                  : const SizedBox(width: 50),

              // Skip button
              showSkip && onSkip != null
                  ? TextButton(
                onPressed: onSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: SetupProfileTheme.darkPink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              ).scale(
                duration: const Duration(milliseconds: 800),
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.05, 1.05),
                curve: Curves.easeInOut,
              )
                  : const SizedBox(width: 50),
            ],
          ),
        ],
      ),
    );
  }
}