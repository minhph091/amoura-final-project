import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../setup_profile_viewmodel.dart';
import 'package:provider/provider.dart';

class SetupProfileButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const SetupProfileButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 52,
  });

  List<Color> _getButtonGradient(int currentStep, int totalSteps) {
    const buttonStart = Color(0xFFD81B60);
    const buttonEnd = Color(0xFF8E24AA);
    double factor = currentStep / (totalSteps - 1);
    final startColor = Color.lerp(buttonStart, buttonEnd, factor) ?? buttonStart;
    final endColor = Color.lerp(buttonEnd, buttonStart, factor) ?? buttonEnd;
    return [startColor, endColor];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = Provider.of<SetupProfileViewModel>(context);
    final colors = _getButtonGradient(vm.currentStep, vm.totalSteps);

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        duration: const Duration(milliseconds: 800),
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.02, 1.02),
        curve: Curves.easeInOut,
      ),
    );
  }
}