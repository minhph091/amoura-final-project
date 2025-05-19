// lib/main.dart

import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(const AmouraApp());
}

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