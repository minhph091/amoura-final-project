// lib/presentation/profile/view/widgets/profile_main_info.dart

import 'package:flutter/material.dart';

class ProfileMainInfo extends StatelessWidget {
  final String? firstName;
  final String? lastName;
  final DateTime? dob;
  final String? gender;

  const ProfileMainInfo({
    super.key,
    this.firstName,
    this.lastName,
    this.dob,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final age = dob != null ? now.year - dob!.year - ((now.month < dob!.month || (now.month == dob!.month && now.day < dob!.day)) ? 1 : 0) : null;
    final displayName = [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Column(
        children: [
          Text(
            displayName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (age != null)
                Text('$age yrs', style: Theme.of(context).textTheme.bodyMedium),
              if (age != null && gender != null) const SizedBox(width: 12),
              if (gender != null)
                Row(
                  children: [
                    Icon(
                      gender == 'Male'
                          ? Icons.male
                          : gender == 'Female'
                          ? Icons.female
                          : Icons.transgender,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gender!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}