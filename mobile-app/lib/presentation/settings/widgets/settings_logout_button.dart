import 'package:flutter/material.dart';
import '../../shared/dialogs/confirm_dialog.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      width: size.width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
          minimumSize: Size(size.width, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(
          Icons.logout_rounded,
          size: 20,
        ),
        label: const Text(
            'Log Out',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
            )
        ),
        onPressed: () => _handleLogout(context),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final result = await showConfirmDialog(
      context: context,
      title: 'Log Out',
      content: 'Are you sure you want to log out of your account?',
      confirmText: 'Yes, Log Out',
      cancelText: 'No, Cancel',
      icon: Icons.logout_rounded,
      iconColor: Theme.of(context).colorScheme.error,
    );

    if (result == true) {
      // Add your logout logic here
      // Example: context.read<AuthViewModel>().logout();
    }
  }
}