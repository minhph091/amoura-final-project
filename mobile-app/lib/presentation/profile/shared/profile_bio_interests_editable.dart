import 'package:flutter/material.dart';

class ProfileBioInterestsEditable extends StatelessWidget {
  final String? bio;
  final List<String>? interests;
  final VoidCallback? onEditBio;
  final VoidCallback? onEditInterests;

  const ProfileBioInterestsEditable({
    super.key,
    this.bio,
    this.interests,
    this.onEditBio,
    this.onEditInterests,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Bio', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (onEditBio != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: "Edit Bio",
                onPressed: onEditBio,
              ),
          ],
        ),
        Text(bio ?? '-', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(
          children: [
            Text('Interests', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (onEditInterests != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: "Edit Interests",
                onPressed: onEditInterests,
              ),
          ],
        ),
        if (interests != null && interests!.isNotEmpty)
          Wrap(
            spacing: 8,
            children: interests!.map((e) => Chip(label: Text(e))).toList(),
          )
        else
          Text("-", style: theme.textTheme.bodyMedium),
      ],
    );
  }
}