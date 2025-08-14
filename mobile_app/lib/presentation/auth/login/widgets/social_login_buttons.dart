// lib/presentation/auth/login/widgets/social_login_button.dart
import 'package:flutter/material.dart';
import '../../../../config/language/app_localizations.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGoogle;
  final VoidCallback? onFacebook;

  const SocialLoginButtons({super.key, this.onGoogle, this.onFacebook});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      children: [
        Text(localizations.translate('or_sign_in_with')),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: 'Sign in with Google',
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: onGoogle,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.10),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logos/google_logo.png',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Tooltip(
              message: 'Sign in with Facebook',
              child: InkWell(
                borderRadius: BorderRadius.circular(32),
                onTap: onFacebook,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.10),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logos/facebook_logo.png',
                    width: 38,
                    height: 38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
