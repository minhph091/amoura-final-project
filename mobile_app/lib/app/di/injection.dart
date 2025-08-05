// lib/app/di/injection.dart
import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/setup_profile_service.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/match_service.dart';
import '../../core/services/chat_service.dart';
import '../../core/services/user_status_service.dart';
import '../../infrastructure/socket/socket_client.dart';
import '../../data/remote/auth_api.dart';
import '../../data/remote/setup_profile_api.dart';
import '../../data/remote/profile_api.dart';
import '../../data/remote/match_api.dart';
import '../../data/remote/chat_api.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/setup_profile_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/update_profile_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/profile/get_profile_usecase.dart';
import '../../domain/usecases/match/get_recommendations_usecase.dart';
import '../../domain/usecases/match/like_user_usecase.dart';
import '../../domain/usecases/match/dislike_user_usecase.dart';
import '../../domain/usecases/match/get_matches_usecase.dart';
import '../../domain/usecases/chat/get_conversations_usecase.dart';
import '../../domain/usecases/chat/get_messages_usecase.dart';
import '../../domain/usecases/chat/send_message_usecase.dart';
import '../../domain/usecases/chat/delete_message_usecase.dart';
import '../../domain/usecases/chat/recall_message_usecase.dart';
import '../../domain/usecases/chat/mark_messages_read_usecase.dart';
import '../../domain/usecases/chat/upload_chat_image_usecase.dart';
import '../../domain/usecases/chat/check_user_online_usecase.dart';
import '../../domain/usecases/chat/get_chat_room_usecase.dart';
import '../../infrastructure/services/subscription_service.dart';
import '../../infrastructure/services/rewind_service.dart';
import '../../infrastructure/services/likes_service.dart';
import 'package:flutter/material.dart';
import '../../data/remote/user_api.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/usecases/user/update_user_usecase.dart';
import '../../data/remote/notification_api.dart';
import '../../core/services/notification_service.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies(
  GlobalKey<NavigatorState> navigatorKey,
) async {
  // Core
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // ApiClient
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      authService: getIt<AuthService>(),
      navigatorKey: navigatorKey,
    ),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<SetupProfileApi>(
    () => SetupProfileApi(getIt<ApiClient>(), getIt<AuthService>()),
  );
  getIt.registerLazySingleton<ProfileApi>(() => ProfileApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<MatchApi>(() => MatchApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<ChatApi>(() => ChatApi(getIt<ApiClient>()));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(getIt<AuthApi>()),
  );
  getIt.registerLazySingleton<SetupProfileRepository>(
    () => SetupProfileRepository(getIt<SetupProfileApi>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(getIt<ProfileApi>()),
  );
  getIt.registerLazySingleton<MatchRepository>(
    () => MatchRepository(getIt<MatchApi>()),
  );
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<ChatApi>()),
  );
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(getIt<ChatApi>()),
  );

  // Services
  getIt.registerLazySingleton<SocketClient>(() => SocketClient());
  getIt.registerLazySingleton<SetupProfileService>(
    () => SetupProfileService(
      setupProfileRepository: getIt<SetupProfileRepository>(),
    ),
  );
  getIt.registerLazySingleton<ProfileService>(() => ProfileService());
  getIt.registerLazySingleton<MatchService>(() => MatchService());
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<UserStatusService>(() => UserStatusService());
  getIt.registerLazySingleton<SubscriptionService>(() => SubscriptionService());
  getIt.registerLazySingleton<RewindService>(() => RewindService());
  getIt.registerLazySingleton<LikesService>(() => LikesService());

  // Use Cases
  getIt.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(getIt<AuthRepository>(), getIt<AuthService>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>(), getIt<AuthService>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>(), getIt<AuthService>()),
  );
  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(getIt<ProfileService>()),
  );

  // Matching Use Cases
  getIt.registerLazySingleton<GetRecommendationsUseCase>(
    () => GetRecommendationsUseCase(getIt<MatchService>()),
  );
  getIt.registerLazySingleton<LikeUserUseCase>(
    () => LikeUserUseCase(getIt<MatchService>()),
  );
  getIt.registerLazySingleton<DislikeUserUseCase>(
    () => DislikeUserUseCase(getIt<MatchService>()),
  );
  getIt.registerLazySingleton<GetMatchesUseCase>(
    () => GetMatchesUseCase(getIt<MatchService>()),
  );

  // Chat Use Cases
  getIt.registerLazySingleton<GetConversationsUseCase>(
    () => GetConversationsUseCase(),
  );
  getIt.registerLazySingleton<GetMessagesUseCase>(() => GetMessagesUseCase());
  getIt.registerLazySingleton<SendMessageUseCase>(() => SendMessageUseCase());
  getIt.registerLazySingleton<DeleteMessageUseCase>(
    () => DeleteMessageUseCase(),
  );
  getIt.registerLazySingleton<RecallMessageUseCase>(
    () => RecallMessageUseCase(),
  );
  getIt.registerLazySingleton<MarkMessagesReadUseCase>(
    () => MarkMessagesReadUseCase(),
  );
  getIt.registerLazySingleton<UploadChatImageUseCase>(
    () => UploadChatImageUseCase(),
  );
  getIt.registerLazySingleton<CheckUserOnlineUseCase>(
    () => CheckUserOnlineUseCase(),
  );
  getIt.registerLazySingleton<GetChatRoomUseCase>(() => GetChatRoomUseCase());

  // User
  getIt.registerLazySingleton<UserApi>(() => UserApi(getIt<ApiClient>()));
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(getIt<UserApi>()),
  );
  getIt.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(getIt<UserRepository>()),
  );

  // Notification
  getIt.registerLazySingleton<NotificationApi>(
    () => NotificationApi(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
}
