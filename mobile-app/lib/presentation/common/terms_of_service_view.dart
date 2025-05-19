// lib/presentation/common/terms_of_service_view.dart

import 'package:flutter/material.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
          fontSize: 18,
        ),
        backgroundColor: colorScheme.surface,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: colorScheme.primary,
        ),
      ),
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề lớn
              Text(
                'AMOURA TERMS OF SERVICE',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              // Thời gian cập nhật
              Text(
                'Last updated: May 19, 2025',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 22),
              _SectionTitle('1. Introduction'),
              _Paragraph(
                  'Welcome to Amoura App provided by the Amoura Team us. '
                      'By accessing or using our Service, you agree to be bound by these Terms of Service. '
                      'If you do not agree with any part of the Terms, you may not access the Service.'),
              _SectionTitle('2. Eligibility'),
              _Paragraph(
                  'You must be at least 18 years old to create an account and use Amoura. '
                      'You are responsible for all activities that occur under your account and for keeping your login credentials secure.'),
              _Paragraph(
                  'You may not use the Service for any illegal or unauthorized purpose. '
                      'You agree to comply with all applicable local, state, national, and international laws and regulations.'),
              _SectionTitle('3. User Content'),
              _Paragraph(
                  'You are solely responsible for the information, text, images, videos, or other materials that you upload, post, or display ("User Content") on the Service. '
                      'We do not endorse any User Content and disclaim all liability for User Content.'),
              _SectionTitle('4. Changes to Terms'),
              _Paragraph(
                  'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. '
                      'If a revision is material we will provide at least 30 days\' notice prior to any new terms taking effect. '
                      'What constitutes a material change will be determined at our sole discretion.'),
              const SizedBox(height: 34),
              Center(
                child: Text(
                  'Thank you for using Amoura!',
                  style: textTheme.titleMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget phụ - Tiêu đề section
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
      child: Text(
        text,
        style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.9)),
      ),
    );
  }
}

// Widget phụ - Đoạn văn bản
class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: textTheme.bodyLarge?.copyWith(
          height: 1.5,
          color: colorScheme.onSurface.withValues(alpha: 0.8),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }
}