import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:stream_sync_lite/data/models/notification_model.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await HiveStorageService.init();
  
  print('📨 Background message received: ${message.notification?.title}');
  
  final notification = message.notification;
  final data = message.data;
  
  if (notification != null) {
    try {
      final body = notification.body ?? '';
      final preview = body.length > 100 ? '${body.substring(0, 100)}...' : body;
      
      final notificationModel = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? 'Notification',
        body: body,
        preview: preview,
        type: data['type'] ?? 'general',
        isRead: false,
        timestamp: DateTime.now(),
        linkedContentId: data['linkedContentId'],
        thumbnailUrl: data['thumbnailUrl'],
        data: data.isNotEmpty ? data : null,
      );
      
      await HiveStorageService.saveNotification(notificationModel);
      print('✅ Background notification saved');
    } catch (e) {
      print('❌ Error saving background notification: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('🚀 Starting app initialization...');
    
    // Load environment variables
    print('📁 Loading environment variables...');
    try {
      await dotenv.load(fileName: "/.env");
      print('✅ Environment variables loaded');
    } catch (e) {
      print('⚠️ No .env file found, using defaults: $e');
    }
    
    // Initialize Firebase
    print('🔥 Initializing Firebase...');
    await Firebase.initializeApp();
    print('✅ Firebase initialized');
    
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background message handler registered');

    // Initialize Hive
    print('💾 Initializing Hive...');
    await HiveStorageService.init();
    print('✅ Hive initialized');

    // Setup dependencies
    print('🔧 Setting up dependencies...');
    await setupDependencies();
    print('✅ Dependencies setup complete');

    // Initialize Firebase Messaging
    print('📲 Initializing Firebase Messaging...');
    await getIt<FirebaseService>().initialize();
    print('✅ Firebase Messaging initialized');

    print('✨ App initialization complete!');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    print('❌ FATAL ERROR during initialization:');
    print('Error: $e');
    print('StackTrace: $stackTrace');
    
    // Show error screen
    runApp(ErrorApp(error: e.toString(), stackTrace: stackTrace.toString()));
  }
}

// Error screen for initialization failures
class ErrorApp extends StatelessWidget {
  final String error;
  final String stackTrace;
  
  const ErrorApp({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        stackTrace,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
