// lib/presentation/profile/view/widgets/profile_bio_interests.dart

import 'package:flutter/material.dart';

class ProfileBioInterests extends StatelessWidget {
  final String? bio;
  final List<String>? interests;

  const ProfileBioInterests({super.key, this.bio, this.interests});

  @override
  Widget build(BuildContext context) {
    final bioText = bio ?? '';
    final hasInterests = interests != null && interests!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (bioText.isNotEmpty)
            Text(
              bioText,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          if (hasInterests) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: interests!
                  .map(
                    (interest) => Chip(
                  label: Text(interest),
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                ),
              )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}