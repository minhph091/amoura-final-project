import 'package:get_it/get_it.dart';

// Re-export the main dependency injection setup
final GetIt serviceLocator = GetIt.instance;

// This file now just re-exports the main injection setup
// All dependencies are configured in lib/app/di/injection.dart
