import 'package:flutter/material.dart';

class SettingsVersionText extends StatelessWidget {
  const SettingsVersionText({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with version from model/provider if needed.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'App version 1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}