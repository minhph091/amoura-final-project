import 'package:amoura/presentation/settings/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import '../../shared/widgets/language_selector_dialog.dart';
import '../../../config/language/language_controller.dart';
import '../../../config/language/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsLanguageSelector extends StatelessWidget {
  const SettingsLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Provider.of<LanguageController>(context);
    final currentLanguageCode = languageController.locale.languageCode;
    final localizations = AppLocalizations.of(context);

    return SettingsTile(
      icon: Icons.language_outlined,
      title: localizations.translate('language'),
      subtitle: languageController.getLanguageName(currentLanguageCode),
      onTap: () => showDialog(
        context: context,
        builder: (_) => const LanguageSelectorDialog(),
      ),
    );
  }
}
