// lib/app/app.dart

import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import 'routes/app_pages.dart';

class AmouraApp extends StatelessWidget {
  const AmouraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Amoura",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppPages.initial,
      onGenerateRoute: AppPages.generateRoute,
    );
  }
}