import 'package:flutter/material.dart';
import '../../setup/theme/setup_profile_theme.dart';

class CollapsibleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;
  final VoidCallback onToggle;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    required this.onToggle,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: initiallyExpanded ? 1.5 : 1,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: ProfileTheme.darkPink),
            title: Text(
              title,
              style: ProfileTheme.getSubtitleStyle(context),
            ),
            trailing: AnimatedRotation(
              turns: initiallyExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: ProfileTheme.darkPink,
              ),
            ),
            onTap: onToggle,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
            crossFadeState: initiallyExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
