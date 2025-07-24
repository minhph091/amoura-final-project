// lib/presentation/discovery/widgets/user_info_section.dart
// User info section for ProfileCard (name, age, location, bio, interests).

import 'package:flutter/material.dart';
import 'interest_chip.dart';

class UserInfoSection extends StatelessWidget {
  final String name;
  final int age;
  final String location;
  final String bio;
  final List<InterestChipData> interests;

  const UserInfoSection({
    super.key,
    required this.name,
    required this.age,
    required this.location,
    required this.bio,
    required this.interests,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(23),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.77),
            Colors.white.withValues(alpha: 0.43),
            Colors.white.withValues(alpha: 0.13),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            spreadRadius: 6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '$age',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.blueGrey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.blueGrey.shade400,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueGrey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            bio,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.pinkAccent,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 17),
          Wrap(
            spacing: 0,
            runSpacing: 0,
            children: interests
                .map((interest) => InterestChip(
                      label: interest.label,
                      icon: interest.icon,
                      iconColor: interest.iconColor,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class InterestChipData {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final Gradient? gradient;

  const InterestChipData({
    required this.label,
    required this.icon,
    required this.iconColor,
    this.borderColor,
    this.gradient,
  });
}
