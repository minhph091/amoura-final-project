// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amoura/data/repositories/user_repository.dart';
import 'package:get_it/get_it.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'app/core/navigation.dart'; // Import the global navigator key
import 'presentation/settings/theme/theme_mode_controller.dart';
import 'config/language/language_controller.dart';
import 'presentation/profile/view/profile_viewmodel.dart';
import 'infrastructure/services/rewind_service.dart';
import 'infrastructure/services/subscription_service.dart';
import 'infrastructure/services/likes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use the global navigatorKey instead of creating a local one
  await configureDependencies(navigatorKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModeController()),
        ChangeNotifierProvider(create: (_) => LanguageController()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()..loadProfile()), // Register ProfileViewModel and load profile data on startup
        Provider<UserRepository>(create: (_) => GetIt.I<UserRepository>()), // Đảm bảo UserRepository luôn có sẵn

        // Thêm các service cho VIP features
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => RewindService()),
        ChangeNotifierProvider(create: (_) => LikesService()),
      ],
      child: AmouraApp(navigatorKey: navigatorKey), // Pass navigatorKey to AmouraApp
    ),
  );
}