import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_sync_lite/core/di/dependency_injection.dart';
import 'package:stream_sync_lite/data/services/firebase_service.dart';
import 'package:stream_sync_lite/data/services/hive_storage_service.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/notification/notification_bloc.dart';
import 'package:stream_sync_lite/presentation/pages/splash_page.dart';
import 'package:stream_sync_lite/presentation/pages/home_page.dart';
import 'package:stream_sync_lite/presentation/pages/login_page.dart';
import 'package:stream_sync_lite/presentation/pages/register_page.dart';
import 'package:stream_sync_lite/presentation/pages/profile_page.dart';
import 'package:stream_sync_lite/presentation/pages/notifications_page.dart';
import 'package:stream_sync_lite/presentation/pages/main_navigation_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive
  await HiveStorageService.init();

  // Setup dependencies
  await setupDependencies();

  // Initialize Firebase Messaging
  await getIt<FirebaseService>().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()),
        BlocProvider(create: (context) => getIt<VideoBloc>()),
        BlocProvider(create: (context) => getIt<NotificationBloc>()),
      ],
      child: MaterialApp(
        title: 'Stream Sync Lite',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: const SplashPage(),
        routes: {
          '/main': (context) => const MainNavigationPage(),
          '/home': (context) => const HomePage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/profile': (context) => const ProfilePage(),
          '/notifications': (context) => const NotificationsPage(),
        },
      ),
    );
  }
}
