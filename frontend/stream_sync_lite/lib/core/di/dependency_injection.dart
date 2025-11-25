import 'package:get_it/get_it.dart';
import 'package:stream_sync_lite/data/repositories/auth_repository.dart';
import 'package:stream_sync_lite/data/services/api_service.dart';
import 'package:stream_sync_lite/data/services/firebase_service.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/notification/notification_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  try {
    print('  📦 Registering services...');
    // Services
    getIt.registerLazySingleton<ApiService>(() => ApiService());
    print('    ✓ ApiService registered');
    
    getIt.registerLazySingleton<FirebaseService>(() => FirebaseService());
    print('    ✓ FirebaseService registered');

    print('  📚 Registering repositories...');
    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        apiService: getIt<ApiService>(),
        firebaseService: getIt<FirebaseService>(),
      ),
    );
    print('    ✓ AuthRepository registered');

    print('  🎯 Registering BLoCs...');
    // BLoCs
    getIt.registerFactory<AuthBloc>(
      () => AuthBloc(authRepository: getIt<AuthRepository>()),
    );
    print('    ✓ AuthBloc registered');
    
    getIt.registerFactory<VideoBloc>(
      () => VideoBloc(apiService: getIt<ApiService>()),
    );
    print('    ✓ VideoBloc registered');
    
    getIt.registerFactory<NotificationBloc>(
      () => NotificationBloc(apiService: getIt<ApiService>()),
    );
    print('    ✓ NotificationBloc registered');
    
    print('  ✅ All dependencies registered successfully');
  } catch (e, stackTrace) {
    print('  ❌ Error during dependency registration:');
    print('  Error: $e');
    print('  StackTrace: $stackTrace');
    rethrow;
  }
}
