import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Divider(
        height: 1,
        thickness: 0.8,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.35),
      ),
    );
  }
}
