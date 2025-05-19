// lib/presentation/auth/login/widget/social_login_button.dart

import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Or sign in with"),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
              tooltip: 'Sign in with Google',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.facebook, size: 32, color: Colors.blue),
              tooltip: 'Sign in with Facebook',
            ),
          ],
        ),
      ],
    );
  }
}