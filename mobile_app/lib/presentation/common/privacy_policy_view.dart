// lib/presentation/privacy/privacy_policy_view.dart

import 'package:flutter/material.dart';
import '../common/common_info_view.dart';
import '../common/info_content_helpers.dart';
import '../../config/theme/text_styles.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonInfoView(
      appBarTitle: 'Privacy Policy',
      mainTitle: 'AMOURA PRIVACY POLICY',
      subtitle: 'Last updated: May 19, 2025',
      children: [
        InfoContentHelpers.buildSectionTitle('1. Information We Collect', colorScheme),
        InfoContentHelpers.buildParagraph(
            'We collect information you provide directly to us. For example: we collect information when you create an account, '
                'complete your profile, post content, interact with other users, or contact customer support.',
            colorScheme),
        InfoContentHelpers.buildParagraph(
            'Types of information may include name, email address, phone number, date of birth, gender, '
                'photos, location, interests, and any other information you choose to provide.',
            colorScheme),
        const SizedBox(height: 16),
        InfoContentHelpers.buildSectionTitle('2. How We Use Information', colorScheme),
        InfoContentHelpers.buildParagraph('We use collected information to:', colorScheme),
        InfoContentHelpers.buildListItem('Provide, maintain, and improve our Services;', colorScheme),
        InfoContentHelpers.buildListItem('Personalize your experience and suggest connections;', colorScheme),
        InfoContentHelpers.buildListItem('Enable you to communicate with other users;', colorScheme),
        InfoContentHelpers.buildListItem('Send you technical notices, updates, security alerts, and support/administrative messages;', colorScheme),
        InfoContentHelpers.buildListItem('Respond to your comments, questions, and requests and provide customer service;', colorScheme),
        InfoContentHelpers.buildListItem('Analyze trends, usage, and activities related to our Services.', colorScheme),
        const SizedBox(height: 16),
        InfoContentHelpers.buildSectionTitle('3. Information Sharing', colorScheme),
        InfoContentHelpers.buildParagraph(
            'We may share information about you as follows or as otherwise described in this Privacy Policy:',
            colorScheme),
        InfoContentHelpers.buildListItem('With other users when you interact on the Service, such as when you matches or chat;', colorScheme),
        InfoContentHelpers.buildListItem('With vendors, consultants, and other service providers who need access to such information to perform work on our behalf;', colorScheme),
        InfoContentHelpers.buildListItem('To comply with any applicable law, regulation, legal process, or governmental request as required;', colorScheme),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'Amoura is committed to protecting your privacy.',
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