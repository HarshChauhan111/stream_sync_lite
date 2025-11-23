import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_sync_lite/core/di/dependency_injection.dart';
import 'package:stream_sync_lite/data/services/firebase_service.dart';
import 'package:stream_sync_lite/data/services/hive_storage_service.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_event.dart';
import 'package:stream_sync_lite/presentation/bloc/auth/auth_state.dart';
import 'package:stream_sync_lite/presentation/pages/login_page.dart';
import 'package:stream_sync_lite/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return BlocProvider(
      create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
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
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is AuthAuthenticated) {
              return const ProfilePage();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
