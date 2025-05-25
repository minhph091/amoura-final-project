// lib/presentation/privacy/privacy_policy_view.dart

import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatefulWidget {
  const PrivacyPolicyView({super.key});

  @override
  State<PrivacyPolicyView> createState() => _PrivacyPolicyViewState();
}

class _PrivacyPolicyViewState extends State<PrivacyPolicyView> with SingleTickerProviderStateMixin {
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

  // Build UI chính của form Privacy Policy
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
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
                'AMOURA PRIVACY POLICY',
                style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: colorScheme.primary,
                    letterSpacing: 1.2
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: May 19, 2025',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('1. Information We Collect', textTheme, colorScheme),
            _buildParagraph(
                'We collect information you provide directly to us. For example: we collect information when you create an account, '
                    'complete your profile, post content, interact with other users, or contact customer support.',
                textTheme, colorScheme),
            _buildParagraph(
                'Types of information may include name, email address, phone number, date of birth, gender, '
                    'photos, location, interests, and any other information you choose to provide.',
                textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('2. How We Use Information', textTheme, colorScheme),
            _buildParagraph('We use collected information to:',
                textTheme, colorScheme),
            _buildListItem('Provide, maintain, and improve our Services;', textTheme, colorScheme),
            _buildListItem('Personalize your experience and suggest connections;', textTheme, colorScheme),
            _buildListItem('Enable you to communicate with other users;', textTheme, colorScheme),
            _buildListItem('Send you technical notices, updates, security alerts, and support/administrative messages;', textTheme, colorScheme),
            _buildListItem('Respond to your comments, questions, and requests and provide customer service;', textTheme, colorScheme),
            _buildListItem('Analyze trends, usage, and activities related to our Services.', textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('3. Information Sharing', textTheme, colorScheme),
            _buildParagraph(
                'We may share information about you as follows or as otherwise described in this Privacy Policy:',
                textTheme, colorScheme),
            _buildListItem('With other users when you interact on the Service, such as when you matches or chat;', textTheme, colorScheme),
            _buildListItem('With vendors, consultants, and other service providers who need access to such information to perform work on our behalf;', textTheme, colorScheme),
            _buildListItem('To comply with any applicable law, regulation, legal process, or governmental request as required;', textTheme, colorScheme),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Amoura is committed to protecting your privacy.',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.secondary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Tiêu đề section
  Widget _buildSectionTitle(String title, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.85)),
      ),
    );
  }

  // Đoạn văn bản thường
  Widget _buildParagraph(String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: textTheme.bodyLarge?.copyWith(
            height: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.75)),
        textAlign: TextAlign.justify,
      ),
    );
  }

  // Dòng list bullet cho section
  Widget _buildListItem(String text, TextTheme textTheme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Icon(Icons.circle, size: 7, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyLarge?.copyWith(height: 1.5, color: colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}