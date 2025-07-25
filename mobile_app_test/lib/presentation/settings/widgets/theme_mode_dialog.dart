// lib/presentation/settings/widgets/theme_mode_dialog.dart

import 'package:flutter/material.dart';
import '../../../config/language/app_localizations.dart';

class ThemeModeDialog extends StatefulWidget {
  final ThemeMode initialMode;

  const ThemeModeDialog({super.key, required this.initialMode});

  @override
  State<ThemeModeDialog> createState() => _ThemeModeDialogState();
}

class _ThemeModeDialogState extends State<ThemeModeDialog> {
  late ThemeMode selectedMode;

  @override
  void initState() {
    super.initState();
    selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizations.translate('choose_app_appearance'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            _buildRadioTile(
              context,
              title: localizations.translate('system'),
              value: ThemeMode.system,
              icon: Icons.settings_suggest_outlined,
            ),
            _buildRadioTile(
              context,
              title: localizations.translate('light'),
              value: ThemeMode.light,
              icon: Icons.light_mode_outlined,
            ),
            _buildRadioTile(
              context,
              title: localizations.translate('dark'),
              value: ThemeMode.dark,
              icon: Icons.dark_mode_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      localizations.translate('cancel'),
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(selectedMode),
                    child: Text(localizations.translate('apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioTile(
    BuildContext context, {
    required String title,
    required ThemeMode value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return RadioListTile<ThemeMode>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      value: value,
      groupValue: selectedMode,
      onChanged: (mode) => setState(() => selectedMode = mode!),
      title: Text(title, style: theme.textTheme.bodyLarge),
      secondary: Icon(icon, color: theme.iconTheme.color),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      activeColor: theme.colorScheme.primary,
    );
  }
}
