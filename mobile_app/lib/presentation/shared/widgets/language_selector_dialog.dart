import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/language/language_controller.dart';
import '../../../config/language/app_localizations.dart';

class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);
    final localizations = AppLocalizations.of(context);
    final languages = languageController.getAvailableLanguages();
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.translate('select_language'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.map((language) => _buildLanguageItem(
              context,
              language['code'] ?? '',
              language['name'] ?? '',
              language['flag'] ?? '',
              languageController.locale.languageCode == language['code'],
              () {
                languageController.changeLanguage(language['code'] ?? 'en');
                Navigator.pop(context);
              }
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context, String code, String name, String flagAsset, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagAsset,
                width: 24,
                height: 16,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.language, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
