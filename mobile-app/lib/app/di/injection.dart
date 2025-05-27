// lib/app/di/injection.dart
import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../data/remote/auth_api.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  getIt.registerSingleton<ApiClient>(ApiClient());
  getIt.registerSingleton<AuthService>(AuthService());

  // Data Sources
  getIt.registerSingleton<AuthApi>(AuthApi(getIt<ApiClient>()));

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepository(getIt<AuthApi>(), getIt<AuthService>()),
  );

  // Use Cases
  getIt.registerSingleton<RegisterUseCase>(
    RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateProfileUseCase>(
    UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(getIt<AuthRepository>(), getIt<AuthService>()),
  );
}