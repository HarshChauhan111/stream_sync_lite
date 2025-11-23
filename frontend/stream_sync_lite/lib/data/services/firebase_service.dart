import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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
        debugPrint('Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Message opened from background: ${message.notification?.title}');
        _handleMessage(message);
      });
    } catch (e) {
      debugPrint('Error initializing Firebase: $e');
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
      debugPrint('Title: ${notification.title}');
      debugPrint('Body: ${notification.body}');
    }

    if (data.isNotEmpty) {
      debugPrint('Data: $data');
    }

    // You can navigate to specific screens based on data
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
