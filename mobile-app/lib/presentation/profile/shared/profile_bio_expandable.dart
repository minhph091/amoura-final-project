import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';
import 'theme/profile_theme.dart';
import 'widgets/expandable_text.dart';

class ProfileBioExpandable extends StatelessWidget {
  final String? bio;
  final List<String>? interests;
  final VoidCallback? onEditBio;
  final VoidCallback? onEditInterests;

  const ProfileBioExpandable({
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
            Icon(Icons.edit_note, color: ProfileTheme.darkPink),
            const SizedBox(width: 8),
            Text('Bio', style: ProfileTheme.getSubtitleStyle(context)),
            if (onEditBio != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: ProfileTheme.darkPink),
                tooltip: "Edit Bio",
                onPressed: onEditBio,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: bio != null && bio!.isNotEmpty
              ? ExpandableText(text: bio!, maxLines: 2)
              : Text("-", style: theme.textTheme.bodyMedium),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(Icons.interests, color: ProfileTheme.darkPink),
            const SizedBox(width: 8),
            Text('Interests', style: ProfileTheme.getSubtitleStyle(context)),
            if (onEditInterests != null)
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: ProfileTheme.darkPink),
                tooltip: "Edit Interests",
                onPressed: onEditInterests,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: interests != null && interests!.isNotEmpty
              ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests!.map((e) => Chip(
              label: Text(e),
              backgroundColor: ProfileTheme.lightPurple,
              labelStyle: TextStyle(color: ProfileTheme.darkPurple),
            )).toList(),
          )
              : Text("-", style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}