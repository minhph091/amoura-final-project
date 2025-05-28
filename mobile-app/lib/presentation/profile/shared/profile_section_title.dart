// lib/presentation/profile/shared/profile_section_title.dart

import 'package:flutter/material.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const ProfileSectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    return Row(
      children: [
        Text(title, style: style),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}