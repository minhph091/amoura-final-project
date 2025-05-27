// lib/presentation/common/terms_of_service_view.dart

import 'package:flutter/material.dart';
import 'common_info_view.dart';
import 'info_content_helpers.dart';
import '../../config/theme/text_styles.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonInfoView(
      appBarTitle: 'Terms of Service',
      mainTitle: 'AMOURA TERMS OF SERVICE',
      subtitle: 'Last updated: May 19, 2025',
      children: [
        InfoContentHelpers.buildSectionTitle('1. Introduction', colorScheme),
        InfoContentHelpers.buildParagraph(
            'Welcome to Amoura App provided by the Amoura Team us. '
                'By accessing or using our Service, you agree to be bound by these Terms of Service. '
                'If you do not agree with any part of the Terms, you may not access the Service.',
            colorScheme),
        InfoContentHelpers.buildSectionTitle('2. Eligibility', colorScheme),
        InfoContentHelpers.buildParagraph(
            'You must be at least 18 years old to create an account and use Amoura. '
                'You are responsible for all activities that occur under your account and for keeping your login credentials secure.',
            colorScheme),
        InfoContentHelpers.buildParagraph(
            'You may not use the Service for any illegal or unauthorized purpose. '
                'You agree to comply with all applicable local, state, national, and international laws and regulations.',
            colorScheme),
        InfoContentHelpers.buildSectionTitle('3. User Content', colorScheme),
        InfoContentHelpers.buildParagraph(
            'You are solely responsible for the information, text, images, videos, or other materials that you upload, post, or display ("User Content") on the Service. '
                'We do not endorse any User Content and disclaim all liability for User Content.',
            colorScheme),
        InfoContentHelpers.buildSectionTitle('4. Changes to Terms', colorScheme),
        InfoContentHelpers.buildParagraph(
            'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. '
                'If a revision is material we will provide at least 30 days\' notice prior to any new terms taking effect. '
                'What constitutes a material change will be determined at our sole discretion.',
            colorScheme),
        const SizedBox(height: 34),
        Center(
          child: Text(
            'Thank you for using Amoura!',
            style: AppTextStyles.heading2.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}