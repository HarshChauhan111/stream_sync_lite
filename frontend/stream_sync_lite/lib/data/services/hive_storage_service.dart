import 'package:hive_flutter/hive_flutter.dart';
import 'package:stream_sync_lite/core/config/app_config.dart';

class HiveStorageService {
  static Box? _authBox;
  static Box? _userBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _authBox = await Hive.openBox(AppConfig.authBoxName);
    _userBox = await Hive.openBox(AppConfig.userBoxName);
  }

  // Access Token
  static Future<void> saveAccessToken(String token) async {
    await _authBox?.put(AppConfig.accessTokenKey, token);
  }

  static String? getAccessToken() {
    return _authBox?.get(AppConfig.accessTokenKey);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _authBox?.put(AppConfig.refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _authBox?.get(AppConfig.refreshTokenKey);
  }

  // User Data
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _userBox?.put(AppConfig.userKey, user);
  }

  static Map<String, dynamic>? getUser() {
    final userData = _userBox?.get(AppConfig.userKey);
    if (userData != null && userData is Map) {
      return Map<String, dynamic>.from(userData);
    }
    return null;
  }

  // Clear all data (logout)
  static Future<void> clearAll() async {
    await _authBox?.clear();
    await _userBox?.clear();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    final accessToken = getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}
