// lib/presentation/common/help_center_view.dart

import 'package:flutter/material.dart';
import 'common_info_view.dart';
import 'info_content_helpers.dart';
import '../../config/theme/text_styles.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  // This method is specific to HelpCenterView, so it stays here.
  Widget _buildFAQItem({
    required String question,
    required String answer,
    required ColorScheme colorScheme,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.heading2.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
          child: Text(
            answer,
            style: AppTextStyles.body.copyWith(
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonInfoView(
      appBarTitle: 'Help Center & FAQ',
      mainTitle: 'AMOURA HELP CENTER',
      subtitle:
          'Find answers to your frequently asked questions and get support from our team.',
      children: [
        InfoContentHelpers.buildSectionTitle(
          'FREQUENTLY ASKED QUESTIONS (FAQ)',
          colorScheme,
        ),
        _buildFAQItem(
          question: 'How do I create an Amoura account?',
          answer:
              'You can create an Amoura account by downloading the app from the App Store or Google Play, then following the registration instructions on the screen.',
          colorScheme: colorScheme,
        ),
        _buildFAQItem(
          question: 'I forgot my password, what should I do?',
          answer:
              'On the login screen, select "Forgot Password?" and follow the instructions to reset your password via your registered email or phone number.',
          colorScheme: colorScheme,
        ),
        _buildFAQItem(
          question: 'How do I update my personal information?',
          answer:
              'Go to "Your Profile" from the app settings. Here you can edit your photos, bio, interests, and other information.',
          colorScheme: colorScheme,
        ),
        _buildFAQItem(
          question: 'How do I report a user?',
          answer:
              'If you encounter inappropriate behavior, you can report the user by visiting their profile and selecting the "Report User" option. We will review your report seriously.',
          colorScheme: colorScheme,
        ),
        _buildFAQItem(
          question: 'How do I delete my Amoura account?',
          answer:
              'You can permanently delete your account under "Settings & Account" -> "Manage Data". Please note that this action cannot be undone.',
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 20),
        InfoContentHelpers.buildSectionTitle('CONTACT US', colorScheme),
        InfoContentHelpers.buildParagraph(
          'If you cannot find the answer to your question here or need further assistance, please contact our support team.',
          colorScheme,
        ),
        const SizedBox(height: 10),
        Text(
          'Email: support@amoura.space', // Replace with actual support email
          style: AppTextStyles.body.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        Text(
          'Working Hours: Monday - Friday, 9:00 AM - 5:00 PM (GMT+7)',
          style: AppTextStyles.body.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'The Amoura Team is always here to help you!',
            style: AppTextStyles.heading2.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
