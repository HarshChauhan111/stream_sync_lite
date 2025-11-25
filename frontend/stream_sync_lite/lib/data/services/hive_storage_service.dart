import 'package:hive_flutter/hive_flutter.dart';
import 'package:stream_sync_lite/core/config/app_config.dart';
import 'package:stream_sync_lite/data/models/notification_model.dart';

class HiveStorageService {
  static Box? _authBox;
  static Box? _userBox;
  static Box<NotificationModel>? _notificationsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(NotificationModelAdapter());
      print('✅ NotificationModel adapter registered');
    }
    
    _authBox = await Hive.openBox(AppConfig.authBoxName);
    _userBox = await Hive.openBox(AppConfig.userBoxName);
    
    // Open notifications box
    try {
      _notificationsBox = await Hive.openBox<NotificationModel>('notifications');
      print('✅ Notifications box opened');
    } catch (e) {
      print('❌ Error opening notifications box: $e');
    }
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

  // Notification Management
  static Future<void> saveNotification(NotificationModel notification) async {
    try {
      await _notificationsBox?.put(notification.id, notification);
    } catch (e) {
      print('Error saving notification: $e');
    }
  }

  static List<NotificationModel> getAllNotifications() {
    try {
      return _notificationsBox?.values.toList() ?? [];
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> deleteNotification(String id) async {
    try {
      await _notificationsBox?.delete(id);
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  static Future<void> markNotificationAsRead(String id) async {
    try {
      final notification = _notificationsBox?.get(id);
      if (notification != null) {
        final updated = notification.copyWith(isRead: true);
        await _notificationsBox?.put(id, updated);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static int getUnreadNotificationCount() {
    try {
      return _notificationsBox?.values.where((n) => !n.isRead).length ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
