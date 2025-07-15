// lib/presentation/welcome/widgets/login_options_bottom_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/language/app_localizations.dart';
import '../../../app/routes/app_routes.dart';

class LoginOptionsBottomSheet extends StatelessWidget {
  const LoginOptionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context);

    final List<Map<String, dynamic>> loginMethods = [
      {
        'label': localizations.translate('email_phone_option'),
        'icon': FontAwesomeIcons.solidEnvelope,
        'color': AppColors.primary,
        'route': AppRoutes.login,
      },
      {
        'label': localizations.translate('otp_verification_option'),
        'icon': FontAwesomeIcons.phoneFlip,
        'color': AppColors.secondary,
        'route': AppRoutes.loginWithEmailOtp,
      },
    ];

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color:
              theme.brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.97)
                  : colorScheme.surface.withValues(alpha: 0.97),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: -12,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 55,
                height: 5.5,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Text(
              localizations.translate('sign_in_with'),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 0.25,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.8,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
              ),
              itemCount: loginMethods.length,
              itemBuilder: (context, index) {
                final method = loginMethods[index];
                return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();

                            if (method['action'] == 'google') {
                              // Handle Google sign in
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Google sign-in coming soon'),
                                ),
                              );
                            } else if (method['action'] == 'facebook') {
                              // Handle Facebook sign in
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Facebook sign-in coming soon'),
                                ),
                              );
                            } else if (method['route'] != null) {
                              // Navigate to login route
                              Navigator.pushNamed(
                                context,
                                method['route'] as String,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations
                                        .translate('login_coming_soon')
                                        .replaceAll(
                                          '{}',
                                          method['label'] as String,
                                        ),
                                  ),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          splashColor: (method['color'] as Color).withValues(
                            alpha: 0.25,
                          ),
                          highlightColor: (method['color'] as Color).withValues(
                            alpha: 0.15,
                          ),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (method['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              border: Border.all(
                                color: (method['color'] as Color).withValues(
                                  alpha: 0.6,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (method['color'] as Color).withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: FaIcon(
                                method['icon'] as IconData,
                                color: method['color'] as Color,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          method['label'] as String,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.9,
                            ),
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(delay: (100 * index).ms, duration: 400.ms)
                    .slideY(begin: 0.3, curve: Curves.easeOutExpo)
                    .scaleXY(
                      begin: 0.85,
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                'CANCEL',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
