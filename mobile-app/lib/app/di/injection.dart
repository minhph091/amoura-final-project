// lib/app/di/injection.dart
import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/setup_profile_service.dart';
import '../../core/services/profile_service.dart';
import '../../data/remote/auth_api.dart';
import '../../data/remote/setup_profile_api.dart';
import '../../data/remote/profile_api.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/setup_profile_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import 'package:flutter/material.dart';
import '../../data/remote/user_api.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/usecases/user/update_user_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies(GlobalKey<NavigatorState> navigatorKey) async {
  // Core
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // ApiClient
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(
        authService: getIt<AuthService>(),
        navigatorKey: navigatorKey,
      ));

  // Data Sources
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<SetupProfileApi>(() => SetupProfileApi(
        getIt<ApiClient>(),
        getIt<AuthService>(),
      ));
  getIt.registerLazySingleton<ProfileApi>(() => ProfileApi(getIt<ApiClient>()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt<AuthApi>(), getIt<AuthService>()));
  getIt.registerLazySingleton<SetupProfileRepository>(() => SetupProfileRepository(getIt<SetupProfileApi>()));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepository(getIt<ProfileApi>()));

  // Services
  getIt.registerLazySingleton<SetupProfileService>(() => SetupProfileService(
        setupProfileRepository: getIt<SetupProfileRepository>(),
      ));
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());

  // Use Cases
  getIt.registerLazySingleton<RefreshTokenUseCase>(() => RefreshTokenUseCase(getIt<AuthRepository>(), getIt<AuthService>()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(() => UpdateProfileUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>(), getIt<AuthService>()));
  getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt<AuthRepository>(), getIt<AuthService>()));
  getIt.registerLazySingleton<GetProfileUseCase>(() => GetProfileUseCase(getIt<ProfileService>()));

  // User
  getIt.registerLazySingleton<UserApi>(() => UserApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt<UserApi>()));
  getIt.registerLazySingleton<UpdateUserUseCase>(() => UpdateUserUseCase(getIt<UserRepository>()));
}