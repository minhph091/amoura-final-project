// lib/presentation/common/info_content_helpers.dart

import 'package:flutter/material.dart';
import '../../config/theme/text_styles.dart';

class InfoContentHelpers {
  // Utility methods for building common content elements
  static Widget buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6.0),
      child: Text(
        title,
        style: AppTextStyles.heading2.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.85),
        ),
      ),
    );
  }

  static Widget buildParagraph(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          height: 1.5,
          color: colorScheme.onSurface.withValues(alpha: 0.75),
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  static Widget buildListItem(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Icon(Icons.circle, size: 7,
                color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(height: 1.5,
                  color: colorScheme.onSurface.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}