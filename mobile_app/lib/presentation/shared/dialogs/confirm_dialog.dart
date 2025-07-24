// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';

typedef DialogActionCallback = Future<void> Function();

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String? confirmText,
  String? cancelText,
  IconData icon = Icons.help_rounded,
  Color? iconColor,
  Widget? additionalContent,
  DialogActionCallback? onConfirm, // if null, default pop(true)
  VoidCallback? onCancel, // optional: run when cancel pressed
}) {
  final localizations = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  // Chọn màu nổi cho tiêu đề dialog khi dark mode (hồng, hoặc bạn có thể đổi sang màu khác nếu muốn)
  final Color titleColor =
      isDark
          ? const Color(0xFFFF69B4) // hồng tươi sáng
          : theme.colorScheme.primary;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor ?? theme.colorScheme.primary,
                size: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22, // Tiêu đề to hơn dialog mặc định
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                    letterSpacing: 0.02,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(content),
              if (additionalContent != null) ...[
                const SizedBox(height: 18),
                additionalContent,
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop(false);
                if (onCancel != null) onCancel();
              },
              child: Text(cancelText ?? localizations.translate('cancel')),
            ),
            Builder(
              builder: (buttonCtx) {
                final isDisabled = onConfirm == null;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDisabled
                            ? theme.disabledColor
                            : theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed:
                      isDisabled
                          ? null
                          : () async {
                            await onConfirm.call();
                            Navigator.of(ctx).pop(true);
                          },
                  child: Text(
                    confirmText ?? localizations.translate('confirm'),
                  ),
                );
              },
            ),
          ],
        ),
  );
}
