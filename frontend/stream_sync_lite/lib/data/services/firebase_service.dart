import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:stream_sync_lite/data/services/hive_storage_service.dart';
import 'package:stream_sync_lite/data/models/notification_model.dart';

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Firebase Messaging
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      await _requestPermission();

      // Get FCM token
      final token = await getToken();
      if (token != null) {
        debugPrint('FCM Token: $token');
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // TODO: Update token on backend
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📨 Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle background messages when app is opened
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📨 Message opened from background: ${message.notification?.title}');
        _handleMessage(message);
      });
      
      debugPrint('✅ Firebase Messaging initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing Firebase: $e');
    }
  }

  // Request notification permission
  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Error requesting permission: $e');
    }
  }

  // Get FCM Token
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  // Get Platform name
  String getPlatform() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else {
      return 'web';
    }
  }

  // Handle incoming message
  void _handleMessage(RemoteMessage message) {
    // Handle notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      debugPrint('📨 Title: ${notification.title}');
      debugPrint('📨 Body: ${notification.body}');
      
      // Save notification to local database
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
        
        HiveStorageService.saveNotification(notificationModel);
        debugPrint('✅ Notification saved to local database');
      } catch (e) {
        debugPrint('❌ Error saving notification: $e');
      }
    }

    if (data.isNotEmpty) {
      debugPrint('📨 Data: $data');
    }
  }

  // Delete FCM Token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
