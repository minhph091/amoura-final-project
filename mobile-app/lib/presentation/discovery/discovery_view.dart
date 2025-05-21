// lib/presentation/discovery/discovery_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverView extends StatelessWidget {
  const DiscoverView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Text(
        "Discovery Screen (Coming Soon)",
        style: theme.textTheme.headlineMedium?.copyWith(
          fontFamily: GoogleFonts.lato().fontFamily,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}