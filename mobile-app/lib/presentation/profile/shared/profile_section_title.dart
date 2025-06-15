import 'package:flutter/material.dart';
import '../setup/theme/setup_profile_theme.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const ProfileSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ProfileTheme.darkPink),
        const SizedBox(width: 8),
        Text(
          title,
          style: ProfileTheme.getSubtitleStyle(context),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}