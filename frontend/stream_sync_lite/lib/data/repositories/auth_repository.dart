import 'package:stream_sync_lite/data/models/auth_response_model.dart';
import 'package:stream_sync_lite/data/models/user_model.dart';
import 'package:stream_sync_lite/data/services/api_service.dart';
import 'package:stream_sync_lite/data/services/firebase_service.dart';
import 'package:stream_sync_lite/data/services/hive_storage_service.dart';

class AuthRepository {
  final ApiService _apiService;
  final FirebaseService _firebaseService;

  AuthRepository({
    required ApiService apiService,
    required FirebaseService firebaseService,
  })  : _apiService = apiService,
        _firebaseService = firebaseService;

  // Register
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.register(
        name: name,
        email: email,
        password: password,
      );

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.data != null) {
        // Save tokens
        await HiveStorageService.saveAccessToken(
            authResponse.data!.accessToken);
        await HiveStorageService.saveRefreshToken(
            authResponse.data!.refreshToken);

        // Save user data
        await HiveStorageService.saveUser(authResponse.data!.user.toJson());

        // Register FCM token after successful registration
        await _registerFcmToken();

        return _userDataToUser(authResponse.data!.user);
      } else {
        throw Exception('Registration failed: No data returned');
      }
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Get FCM token before login
      final fcmToken = await _firebaseService.getToken();
      final platform = _firebaseService.getPlatform();

      final response = await _apiService.login(
        email: email,
        password: password,
        fcmToken: fcmToken,
        platform: platform,
      );

      final authResponse = AuthResponse.fromJson(response);

      if (authResponse.data != null) {
        // Save tokens
        await HiveStorageService.saveAccessToken(
            authResponse.data!.accessToken);
        await HiveStorageService.saveRefreshToken(
            authResponse.data!.refreshToken);

        // Save user data
        await HiveStorageService.saveUser(authResponse.data!.user.toJson());

        // Register FCM token after successful login
        await _registerFcmToken();
        print('✅ FCM token registered after login');

        return _userDataToUser(authResponse.data!.user);
      } else {
        throw Exception('Login failed: No data returned');
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Get Current User
  Future<User> getCurrentUser() async {
    try {
      final userData = HiveStorageService.getUser();
      if (userData != null) {
        return User.fromJson(userData);
      }

      // Fetch from API if not in local storage
      final response = await _apiService.getUserProfile();
      final userJson = response['data']['user'] as Map<String, dynamic>;
      final user = User.fromJson(userJson);

      // Save to local storage
      await HiveStorageService.saveUser(userJson);

      return user;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Refresh Token
  Future<void> refreshTokens() async {
    try {
      final refreshToken = HiveStorageService.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await _apiService.refreshToken(refreshToken);
      final data = response['data'] as Map<String, dynamic>;

      await HiveStorageService.saveAccessToken(data['accessToken'] as String);
      await HiveStorageService.saveRefreshToken(data['refreshToken'] as String);
    } catch (e) {
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Get FCM token before clearing
      final fcmToken = await _firebaseService.getToken();

      // Unregister FCM token from backend
      if (fcmToken != null) {
        try {
          await _apiService.unregisterFcmToken(fcmToken);
        } catch (e) {
          // Continue with logout even if FCM unregister fails
          print('FCM unregister failed: $e');
        }
      }

      // Delete FCM token from device
      await _firebaseService.deleteToken();

      // Clear local storage
      await HiveStorageService.clearAll();
    } catch (e) {
      // Always clear local storage even if API call fails
      await HiveStorageService.clearAll();
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return HiveStorageService.isLoggedIn();
  }

  // Register FCM Token (helper method)
  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await _firebaseService.getToken();
      if (fcmToken != null) {
        final platform = _firebaseService.getPlatform();
        await _apiService.registerFcmToken(
          token: fcmToken,
          platform: platform,
        );
      }
    } catch (e) {
      print('FCM registration failed: $e');
      // Don't throw error, FCM is optional
    }
  }

  // Convert UserData to User
  User _userDataToUser(UserData userData) {
    return User(
      id: userData.id,
      name: userData.name,
      email: userData.email,
      role: userData.role,
      createdAt: DateTime.parse(userData.createdAt),
      updatedAt: DateTime.parse(userData.updatedAt),
    );
  }
}
