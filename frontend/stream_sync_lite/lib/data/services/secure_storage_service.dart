import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  final _logger = Logger();

  // Keys for secure storage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _fcmTokenKey = 'fcm_token';

  // Save access token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
      _logger.d('Access token saved securely');
    } catch (e) {
      _logger.e('Error saving access token: $e');
      rethrow;
    }
  }

  // Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      _logger.e('Error reading access token: $e');
      return null;
    }
  }

  // Save refresh token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
      _logger.d('Refresh token saved securely');
    } catch (e) {
      _logger.e('Error saving refresh token: $e');
      rethrow;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.e('Error reading refresh token: $e');
      return null;
    }
  }

  // Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      _logger.d('User ID saved securely');
    } catch (e) {
      _logger.e('Error saving user ID: $e');
      rethrow;
    }
  }

  // Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.e('Error reading user ID: $e');
      return null;
    }
  }

  // Save FCM token
  Future<void> saveFcmToken(String token) async {
    try {
      await _storage.write(key: _fcmTokenKey, value: token);
      _logger.d('FCM token saved securely');
    } catch (e) {
      _logger.e('Error saving FCM token: $e');
      rethrow;
    }
  }

  // Get FCM token
  Future<String?> getFcmToken() async {
    try {
      return await _storage.read(key: _fcmTokenKey);
    } catch (e) {
      _logger.e('Error reading FCM token: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Clear all secure data (logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.d('All secure data cleared');
    } catch (e) {
      _logger.e('Error clearing secure data: $e');
      rethrow;
    }
  }

  // Clear specific key
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
      _logger.d('Key $key deleted from secure storage');
    } catch (e) {
      _logger.e('Error deleting key $key: $e');
      rethrow;
    }
  }
}
