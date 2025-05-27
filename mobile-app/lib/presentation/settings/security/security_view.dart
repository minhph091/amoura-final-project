import 'package:flutter/material.dart';
import 'widgets/change_password_form.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    // Account security options
    return Scaffold(
      appBar: AppBar(title: const Text('Account Security')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Change Password'),
            onTap: () => showDialog(
              context: context,
              builder: (_) => const ChangePasswordForm(),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_person_outlined),
            title: const Text('Deactivate Account'),
            onTap: () {
              // Show dialog to confirm deactivation
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Delete Account Permanently'),
            onTap: () {
              // Show dialog to confirm deletion
            },
          ),
        ],
      ),
    );
  }
}