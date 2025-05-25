// lib/screens/common/cookie_policy_view.dart

import 'package:flutter/material.dart';

class CookiePolicyView extends StatefulWidget {
  const CookiePolicyView({super.key});

  @override
  State<CookiePolicyView> createState() => _CookiePolicyViewState();
}

class _CookiePolicyViewState extends State<CookiePolicyView> with SingleTickerProviderStateMixin {
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
        title: const Text('Cookie Policy'),
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
                'AMOURA COOKIE POLICY',
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
              'Last updated: May 19, 2025',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('1. What Are Cookies?', textTheme, colorScheme),
            _buildParagraph(
                'Cookies are small text files placed on your device (computer, phone, tablet) when you visit a website or use an application. '
                    'They are widely used to make websites work or work more efficiently, as well as to provide information to the website owner.',
                textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('2. How Amoura Uses Cookies', textTheme, colorScheme),
            _buildParagraph(
                'We use cookies and similar tracking technologies (such as web beacons and pixels) for the following purposes:',
                textTheme, colorScheme),
            _buildListItem('To operate our Services: Essential cookies enable you to navigate the website and use our features.', textTheme, colorScheme),
            _buildListItem('To improve performance: Cookies help us understand how you use our Services to improve your experience.', textTheme, colorScheme),
            _buildListItem('To provide personalized features: Cookies help us remember your preferences and deliver relevant content.', textTheme, colorScheme),
            _buildListItem('To analyze and research: Cookies help us collect information about how you interact with our Services, including the pages you visit and the links you click.', textTheme, colorScheme),
            _buildListItem('For advertising: We may use cookies to display ads that are relevant to your interests.', textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('3. Types of Cookies We Use', textTheme, colorScheme),
            _buildListItem('Essential Cookies: These cookies are necessary for you to move around the website and use its features.', textTheme, colorScheme),
            _buildListItem('Performance Cookies: These cookies collect information about how you use a website, such as the pages you visit most often.', textTheme, colorScheme),
            _buildListItem('Functional Cookies: These cookies allow the website to remember choices you make (such as your username, language, or region) and provide enhanced, personalized features.', textTheme, colorScheme),
            _buildListItem('Advertising/Targeting Cookies: These cookies are used to deliver ads more relevant to you and your interests.', textTheme, colorScheme),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Managing Your Cookie Settings', textTheme, colorScheme),
            _buildParagraph(
                'Most web browsers allow you to manage cookies through your browser settings. However, restricting websites from setting cookies may reduce your overall user experience. '
                    'You can learn more about managing cookies on your browser via the following links (e.g.): Chrome, Firefox, Safari, Edge.',
                textTheme, colorScheme),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'For more information about our Privacy Policy, please visit the relevant section.',
                style: textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.secondary,
                ),
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