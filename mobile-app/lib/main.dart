import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'presentation/settings/theme/theme_mode_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeModeController(),
      child: const AmouraApp(),
    ),
  );
}