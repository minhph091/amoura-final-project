// library presentation/settings/security/account_management/widgets/deactivate_account_dialog.dart

import 'package:flutter/material.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../account_management_viewmodel.dart';

Future<bool?> showDeactivateAccountDialog(
    BuildContext context, AccountManagementViewModel viewModel) {
  return showConfirmDialog(
    context: context,
    title: 'Deactivate Account?',
    content: 'When you deactivate your account:\n\n'
        '• Your profile will no longer be visible to others.\n'
        '• You will not receive notifications from the app.\n'
        '• You can reactivate your account at any time by logging in again.',
    confirmText: 'Deactivate Now',
    cancelText: 'Cancel',
    icon: Icons.lock_person_outlined,
    iconColor: Colors.orange,
    additionalContent: _buildConfirmationCheckbox(
      context,
      viewModel,
      'I understand that deactivating will hide my profile, and I can reactivate it later.',
    ),
    onConfirm: viewModel.iUnderstandTheRisk
        ? () {
      viewModel.onDeactivateConfirmed(context);
      return Future<void>.value();
    }
        : null,
  );
}

Widget _buildConfirmationCheckbox(
    BuildContext context, AccountManagementViewModel viewModel, String riskConfirmationText) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outline.withValues(alpha:0.2)),
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
                    viewModel.setIUnderstandTheRisk(!viewModel.iUnderstandTheRisk);
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    riskConfirmationText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha:0.9),
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