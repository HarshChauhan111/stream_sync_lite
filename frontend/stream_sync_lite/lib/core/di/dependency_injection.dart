import 'package:get_it/get_it.dart';
import 'package:stream_sync_lite/data/repositories/auth_repository.dart';
import 'package:stream_sync_lite/data/services/api_service.dart';
import 'package:stream_sync_lite/data/services/firebase_service.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/notification/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      apiService: getIt<ApiService>(),
      firebaseService: getIt<FirebaseService>(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );
  
  getIt.registerFactory<VideoBloc>(
    () => VideoBloc(apiService: getIt<ApiService>()),
  );
  
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(apiService: getIt<ApiService>()),
  );
}
