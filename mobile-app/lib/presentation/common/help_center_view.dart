// lib/screens/common/help_center_view.dart

import 'package:flutter/material.dart';

class HelpCenterView extends StatefulWidget {
  const HelpCenterView({super.key});

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInTitle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this);
    _fadeInTitle = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center & FAQ'),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          fontSize: 18,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        centerTitle: true,
      ),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeInTitle,
              child: Text(
                'WELCOME TO AMOURA HELP CENTER',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find answers to your frequently asked questions and get support from our team.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('FREQUENTLY ASKED QUESTIONS (FAQ)', textTheme, colorScheme),
            _buildFAQItem(
              question: 'How do I create an Amoura account?',
              answer: 'You can create an Amoura account by downloading the app from the App Store or Google Play, then following the registration instructions on the screen.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'I forgot my password, what should I do?',
              answer: 'On the login screen, select "Forgot Password?" and follow the instructions to reset your password via your registered email or phone number.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'How do I update my personal information?',
              answer: 'Go to "Your Profile" from the app settings. Here you can edit your photos, bio, interests, and other information.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'How do I report a user?',
              answer: 'If you encounter inappropriate behavior, you can report the user by visiting their profile and selecting the "Report User" option. We will review your report seriously.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            _buildFAQItem(
              question: 'How do I delete my Amoura account?',
              answer: 'You can permanently delete your account under "Settings & Account" -> "Manage Data". Please note that this action cannot be undone.',
              textTheme: textTheme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('CONTACT US', textTheme, colorScheme),
            _buildParagraph(
                'If you cannot find the answer to your question here or need further assistance, please contact our support team.',
                textTheme, colorScheme),
            const SizedBox(height: 10),
            Text(
              'Email: support@amoura.com', // Replace with actual support email
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
            Text(
              'Working Hours: Monday - Friday, 9:00 AM - 5:00 PM (GMT+7)',
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'The Amoura Team is always here to help you!',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    return ExpansionTile(
      title: Text(
        question,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 10.0),
          child: Text(
            answer,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: colorScheme.onSurface.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}