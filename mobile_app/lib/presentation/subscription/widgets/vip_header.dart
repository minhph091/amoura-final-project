import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VipHeader extends StatelessWidget {
  const VipHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // VIP logo/badge
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFF06292), Color(0xFFD81B60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD81B60).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              "VIP",
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // VIP tagline
        Text(
          "Elevate Your Dating Experience",
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms),

        const SizedBox(height: 12),

        // VIP description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Unlock premium features and enhance your chances of finding the perfect match with Amoura VIP membership",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
        ),
      ],
    );
  }
}
