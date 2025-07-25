// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/core/navigation.dart';
import 'presentation/settings/theme/theme_mode_controller.dart';
import 'config/language/language_controller.dart';
import 'presentation/profile/view/profile_viewmodel.dart';
import 'infrastructure/services/rewind_service.dart';
import 'infrastructure/services/subscription_service.dart';
import 'infrastructure/services/likes_service.dart';

Future<void> runMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..loadProfile()),
        Provider<UserRepository>(create: (_) => GetIt.I<UserRepository>()),

        // VIP features
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => RewindService()),
        ChangeNotifierProvider(create: (_) => LikesService()),
      ],
      child: AmouraApp(navigatorKey: navigatorKey),
    ),
  );
}
