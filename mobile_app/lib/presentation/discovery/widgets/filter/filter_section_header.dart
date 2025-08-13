// lib/presentation/discovery/widgets/filter_section_header.dart

import 'package:flutter/material.dart';
import '../../../../config/theme/text_styles.dart';

// A reusable header for filter sections.
class FilterSectionHeader extends StatelessWidget {
  final String title;
  final String? valueDisplay;

  const FilterSectionHeader({
    super.key,
    required this.title,
    this.valueDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.heading2.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              fontFamily: 'Roboto',
            ),
          ),
          if (valueDisplay != null)
            Text(
              valueDisplay!,
              style: AppTextStyles.body.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
        ],
      ),
    );
  }
}
