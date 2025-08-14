import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/language/language_controller.dart';
import 'language_selector_dialog.dart';

class LanguageSelector extends StatelessWidget {
  final bool isCompact;

  const LanguageSelector({
    super.key,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);
    final currentLanguageCode = languageController.locale.languageCode;
    final theme = Theme.of(context);

    // Map để hiển thị tên rút gọn của ngôn ngữ
    final Map<String, String> shortNames = {
      'en': 'ENG',
      'vi': 'VN',
    };

    return InkWell(
      onTap: () => _showLanguageDialog(context),
      borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: isCompact ? 4 : 8
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          color: theme.colorScheme.surface.withValues(alpha: 0.7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(isCompact ? 3 : 4),
              child: Image.asset(
                'assets/icons/flag_$currentLanguageCode.png',
                width: isCompact ? 16 : 24,
                height: isCompact ? 12 : 16,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.language, size: 16),
              ),
            ),
            SizedBox(width: isCompact ? 4 : 8),
            Text(
              isCompact ? shortNames[currentLanguageCode] ?? 'EN' : languageController.getLanguageName(currentLanguageCode),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isCompact ? 12 : 14,
              ),
            ),
            SizedBox(width: isCompact ? 2 : 4),
            Icon(
              Icons.arrow_drop_down,
              size: isCompact ? 16 : 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LanguageSelectorDialog(),
    );
  }
}
