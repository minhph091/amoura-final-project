// lib/presentation/settings/legal_resources/legal_resources_view.dart

import 'package:flutter/material.dart';
import '../../common/help_center_view.dart';
import '../../common/privacy_policy_view.dart';
import '../../common/terms_of_service_view.dart';
import '../../common/cookie_policy_view.dart';

class LegalResourcesView extends StatelessWidget {
  const LegalResourcesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal & Resources'),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        children: [
          _buildResourceTile(
            context: context,
            title: 'Help Center',
            icon: Icons.help_outline_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterView()),
            ),
          ),
          _buildResourceTile(
            context: context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyView()),
            ),
          ),
          _buildResourceTile(
            context: context,
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServiceView()),
            ),
          ),
          _buildResourceTile(
            context: context,
            title: 'Cookie Policy',
            icon: Icons.cookie_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CookiePolicyView()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.primary.withValues(alpha: 0.8),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}