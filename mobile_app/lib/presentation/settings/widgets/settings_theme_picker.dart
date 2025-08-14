// lib/presentation/settings/widgets/settings_theme_picker.dart

import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';
import 'theme_mode_dialog.dart';
import 'settings_tile.dart';

class SettingsThemePicker extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onChanged;

  const SettingsThemePicker({
    super.key,
    required this.currentThemeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SettingsTile(
      icon: Icons.palette_outlined,
      title: localizations.translate('app_appearance'),
      subtitle: _subtitle(currentThemeMode, localizations),
      onTap: () async {
        final ThemeMode? picked = await showDialog<ThemeMode>(
          context: context,
          builder: (_) => ThemeModeDialog(initialMode: currentThemeMode),
        );
        if (picked != null && picked != currentThemeMode) {
          onChanged(picked);
        }
      },
    );
  }

  String _subtitle(ThemeMode mode, AppLocalizations localizations) {
    switch (mode) {
      case ThemeMode.system:
        return localizations.translate('follow_system_setting');
      case ThemeMode.light:
        return localizations.translate('light');
      case ThemeMode.dark:
        return localizations.translate('dark');
    }
  }
}
