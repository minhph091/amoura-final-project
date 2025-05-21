// lib/app/app.dart

import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import 'routes/app_pages.dart';

class AmouraApp extends StatelessWidget {
  const AmouraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amoura',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppPages.generateRoute,
      initialRoute: AppPages.initial,
      debugShowCheckedModeBanner: false,
    );
  }
}