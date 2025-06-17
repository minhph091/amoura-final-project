import 'package:amoura/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../config/language/app_localizations.dart';
import '../config/language/language_controller.dart';
import '../config/theme/app_theme.dart';
import '../presentation/settings/theme/theme_mode_controller.dart';
import 'routes/app_pages.dart';

class AmouraApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AmouraApp({required this.navigatorKey, super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeModeController>(context);
    final languageController = Provider.of<LanguageController>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Amoura',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      onGenerateRoute: AppPages.generateRoute,
      initialRoute: AppRoutes.splash,
      debugShowCheckedModeBanner: false,

      // Localization support
      locale: languageController.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}