// lib/presentation/discovery/widgets/interest_chip.dart
// Interest chip widget for displaying user interests.

import 'package:flutter/material.dart';

class InterestChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final Gradient? gradient;

  const InterestChip({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    this.borderColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0, bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? iconColor.withValues(alpha: 0.33),
            width: 2,
          ),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: .07),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}