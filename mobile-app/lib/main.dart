// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'presentation/settings/theme/theme_mode_controller.dart';
import 'config/language/language_controller.dart';
import 'presentation/profile/view/profile_viewmodel.dart'; // Import ProfileViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final navigatorKey = GlobalKey<NavigatorState>();
  await configureDependencies(navigatorKey); // Pass the navigatorKey

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..loadProfile()), // Register ProfileViewModel and load profile data on startup
      ],
      child: AmouraApp(navigatorKey: navigatorKey), // Pass navigatorKey to AmouraApp
    ),
  );
}