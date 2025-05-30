import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import 'routes/app_pages.dart';

class AmouraApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey; // Thêm thuộc tính navigatorKey

  const AmouraApp({required this.navigatorKey, super.key}); // Thêm vào constructor

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Sử dụng navigatorKey đã truyền vào
      title: 'Amoura',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppPages.generateRoute,
      initialRoute: AppPages.initial, // Sử dụng initialRoute thay vì home
      debugShowCheckedModeBanner: false,
    );
  }
}