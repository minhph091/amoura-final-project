import 'package:get_it/get_it.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  serviceLocator.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(),
  );

  serviceLocator.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );

  // Add other dependencies here
}
