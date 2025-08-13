import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/app/app.dart';
import 'package:amoura/app/di/injection.dart';
import 'package:amoura/config/language/language_controller.dart';
import 'package:amoura/presentation/settings/theme/theme_mode_controller.dart';

void runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  final navigatorKey = GlobalKey<NavigatorState>();
  await configureDependencies(navigatorKey);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
      ],
      child: AmouraApp(
        navigatorKey: navigatorKey,
      ),
    ),
  );
}
