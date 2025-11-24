import 'package:flutter_dotenv/flutter_dotenv.dart';
class AppConfig {
  // Backend API Configuration
  static final  baseUrl = dotenv.env['API_URL'];
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String getUserEndpoint = '/auth/me';
  static const String registerFcmEndpoint = '/fcm/register';
  static const String unregisterFcmEndpoint = '/fcm/unregister';
  
  // Hive Box Names
  static const String authBoxName = 'authBox';
  static const String userBoxName = 'userBox';
  
  // Hive Keys
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';
  static const String userKey = 'user';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
