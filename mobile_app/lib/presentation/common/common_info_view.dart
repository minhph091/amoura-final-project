// lib/presentation/common/common_info_view.dart

import 'package:flutter/material.dart';
import '../../config/theme/text_styles.dart';

class CommonInfoView extends StatefulWidget {
  final String appBarTitle;
  final String mainTitle;
  final String? subtitle;
  final List<Widget> children;

  const CommonInfoView({
    super.key,
    required this.appBarTitle,
    required this.mainTitle,
    this.subtitle,
    required this.children,
  });

  @override
  State<CommonInfoView> createState() => _CommonInfoViewState();
}

class _CommonInfoViewState extends State<CommonInfoView> with SingleTickerProviderStateMixin {
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
        titleTextStyle: AppTextStyles.heading2.copyWith(
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _fadeInTitle,
              child: Text(
                widget.mainTitle,
                style: AppTextStyles.heading1.copyWith(
                  color: colorScheme.primary,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                style: AppTextStyles.body.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 22),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}
