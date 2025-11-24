import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stream_sync_lite/core/config/app_config.dart';
import 'package:stream_sync_lite/data/services/hive_storage_service.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? fcmToken,
    String? platform,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
      };

      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['fcmToken'] = fcmToken;
      }
      if (platform != null && platform.isNotEmpty) {
        body['platform'] = platform;
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Refresh Token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.refreshTokenEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = HiveStorageService.getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.getUserEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Register FCM Token
  Future<Map<String, dynamic>> registerFcmToken({
    required String token,
    required String platform,
  }) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}${AppConfig.registerFcmEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'token': token,
          'platform': platform,
        }),
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Unregister FCM Token
  Future<Map<String, dynamic>> unregisterFcmToken(String fcmToken) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final request = http.Request(
        'DELETE',
        Uri.parse('${AppConfig.baseUrl}${AppConfig.unregisterFcmEndpoint}'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
      request.body = jsonEncode({'token': fcmToken});

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Videos
  Future<List<Map<String, dynamic>>> getVideos({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/videos?limit=$limit&offset=$offset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['videos'] ?? []);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Video By ID
  Future<Map<String, dynamic>?> getVideoById(String videoId) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/videos/$videoId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      final data = _handleResponse(response);
      return data['video'] as Map<String, dynamic>?;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Update Video Progress
  Future<bool> updateVideoProgress(String videoId, int position) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/videos/$videoId/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'position': position}),
      ).timeout(AppConfig.connectionTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Toggle Favorite
  Future<bool> toggleFavorite(String videoId) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/videos/$videoId/favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Favorites
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/videos/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['favorites'] ?? []);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get Notifications
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.get(
        Uri.parse('${AppConfig.baseUrl}/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Mark Notification as Read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.patch(
        Uri.parse('${AppConfig.baseUrl}/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Mark All Notifications as Read
  Future<bool> markAllNotificationsAsRead() async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.patch(
        Uri.parse('${AppConfig.baseUrl}/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(AppConfig.connectionTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Delete Notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final request = http.Request(
        'DELETE',
        Uri.parse('${AppConfig.baseUrl}/notifications/$notificationId'),
      );
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Send Test Push
  Future<bool> sendTestPush({
    required String title,
    required String body,
  }) async {
    try {
      final accessToken = HiveStorageService.getAccessToken();
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _client.post(
        Uri.parse('${AppConfig.baseUrl}/fcm/test-push'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
        }),
      ).timeout(AppConfig.connectionTimeout);

      _handleResponse(response);
      return true;
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 'Unknown error occurred';
      throw Exception(message);
    }
  }
}
