// lib/presentation/discovery/widgets/filter_action_buttons.dart

import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/text_styles.dart';
import '../../../../config/language/app_localizations.dart';

// Contains the "Reset" and "Apply" buttons for the filter dialog.
class FilterActionButtons extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterActionButtons({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 10.0,
      ), // Independent padding
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.secondary, width: 2),
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: AppTextStyles.button.copyWith(fontSize: 16),
              ),
              child: Text(localizations.translate('reset')),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                elevation: 0,
              ),
              child: Text(localizations.translate('apply')),
            ),
          ),
        ],
      ),
    );
  }
}
