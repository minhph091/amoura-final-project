// lib/presentation/common/cookie_policy_view.dart

import 'package:flutter/material.dart';
import 'common_info_view.dart';
import 'info_content_helpers.dart';
import '../../config/theme/text_styles.dart';

class CookiePolicyView extends StatelessWidget {
  const CookiePolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonInfoView(
      appBarTitle: 'Cookie Policy',
      mainTitle: 'AMOURA COOKIE POLICY',
      subtitle: 'Last updated: May 19, 2025',
      children: [
        InfoContentHelpers.buildSectionTitle('What Are Cookies', colorScheme),
        InfoContentHelpers.buildParagraph(
          'Cookies are small text files that are placed on your device when you visit a website. '
              'They are widely used to make websites work more efficiently and provide information to the website owners.',
          colorScheme,
        ),

        const SizedBox(height: 16),
        InfoContentHelpers.buildSectionTitle('How We Use Cookies', colorScheme),
        InfoContentHelpers.buildParagraph('We use cookies for several purposes:', colorScheme),
        InfoContentHelpers.buildListItem('Authentication - We use cookies to identify you when you visit our website.', colorScheme),
        InfoContentHelpers.buildListItem('Security - We use cookies to help identify and prevent security risks.', colorScheme),
        InfoContentHelpers.buildListItem('Preferences - We use cookies to remember your settings and preferences.', colorScheme),
        InfoContentHelpers.buildListItem('Analytics - We use cookies to help us understand how visitors interact with our website.', colorScheme),

        const SizedBox(height: 16),
        InfoContentHelpers.buildSectionTitle('Types of Cookies We Use', colorScheme),
        InfoContentHelpers.buildParagraph('Our website uses the following types of cookies:', colorScheme),
        InfoContentHelpers.buildListItem('Essential cookies - These are necessary for the website to function properly.', colorScheme),
        InfoContentHelpers.buildListItem('Preference cookies - These remember your preferences.', colorScheme),
        InfoContentHelpers.buildListItem('Analytics cookies - These help us understand how visitors interact with our website.', colorScheme),

        const SizedBox(height: 30),
        Center(
          child: Text(
            'You can manage cookies through your browser settings.',
            style: AppTextStyles.heading2.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.secondary,
            ),
          ),
        )
      ],
    );
  }
}
