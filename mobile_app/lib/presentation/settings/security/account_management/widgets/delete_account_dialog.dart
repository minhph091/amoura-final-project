// lib/presentation/settings/security/account_management/widgets/delete_account_dialog.dart

import 'package:flutter/material.dart';
import '../../../../../config/language/app_localizations.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../account_management_viewmodel.dart';

Future<bool?> showDeleteAccountDialog(
  BuildContext context,
  AccountManagementViewModel viewModel,
) {
  final localizations = AppLocalizations.of(context);
  return showConfirmDialog(
    context: context,
    title: localizations.translate('delete_account_title'),
    content: localizations.translate('delete_account_info'),
    confirmText: localizations.translate('delete_account'),
    cancelText: localizations.translate('cancel'),
    icon: Icons.delete_forever,
    iconColor: Colors.red,
    additionalContent: _buildConfirmationCheckbox(
      context,
      viewModel,
      localizations.translate('delete_confirmation'),
    ),
    onConfirm:
        viewModel.iUnderstandTheRisk
            ? () {
              viewModel.onDeleteConfirmed(context);
              return Future<void>.value();
            }
            : null,
  );
}

Widget _buildConfirmationCheckbox(
  BuildContext context,
  AccountManagementViewModel viewModel,
  String riskConfirmationText,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox.adaptive(
              value: viewModel.iUnderstandTheRisk,
              onChanged: (bool? value) {
                setState(() {
                  viewModel.setIUnderstandTheRisk(value ?? false);
                });
              },
              activeColor: colorScheme.primary,
              checkColor: colorScheme.onPrimary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    viewModel.setIUnderstandTheRisk(
                      !viewModel.iUnderstandTheRisk,
                    );
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    riskConfirmationText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.9,
                      ),
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.05,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
