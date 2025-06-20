// lib/presentation/settings/widgets/settings_theme_picker.dart

import 'package:flutter/material.dart';
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
    return SettingsTile(
      icon: Icons.palette_outlined,
      title: 'App Appearance',
      subtitle: _subtitle(currentThemeMode),
      onTap: () async {
        final ThemeMode? picked = await showDialog<ThemeMode>(
          context: context,
          builder: (_) => ThemeModeDialog(
            initialMode: currentThemeMode,
          ),
        );
        if (picked != null && picked != currentThemeMode) {
          onChanged(picked);
        }
      },
    );
  }

  String _subtitle(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system setting';
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
    }
  }
}