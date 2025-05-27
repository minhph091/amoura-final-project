import 'package:flutter/material.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 16, bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: colorScheme.error.withValues(alpha: 0.8),
              backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colorScheme.error.withValues(alpha: 0.2)),
              ),
            ),
            icon: Icon(
              Icons.logout_rounded,
              size: 18,
            ),
            label: const Text('Log Out', style: TextStyle(fontSize: 13)),
            onPressed: () {
              // Show confirmation dialog here, then handle logout logic via ViewModel.
            },
          ),
        ),
      ),
    );
  }
}