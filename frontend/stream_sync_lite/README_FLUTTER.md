# Stream Sync Lite - Flutter Frontend

A Flutter application with authentication, JWT token storage using Hive, and Firebase Cloud Messaging (FCM) integration. Built with MVVM + BLoC architecture.

## Features

✅ **Authentication**
- Login with email/password
- Register new account
- Auto token refresh
- Secure logout with FCM cleanup

✅ **State Management**
- BLoC pattern for authentication
- Clean MVVM architecture
- Dependency injection with GetIt

✅ **Local Storage**
- Hive for JWT tokens
- Secure token storage
- User data persistence

✅ **Push Notifications**
- Firebase Cloud Messaging
- Auto FCM token registration on login
- Platform detection (Android/iOS/Web)

✅ **UI/UX**
- Material Design 3
- Responsive layouts
- Loading states
- Error handling
- Pull-to-refresh

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart           # API endpoints, constants
│   └── di/
│       └── dependency_injection.dart  # GetIt setup
│
├── data/
│   ├── models/
│   │   ├── auth_response_model.dart
│   │   └── user_model.dart
│   ├── repositories/
│   │   └── auth_repository.dart      # Business logic layer
│   └── services/
│       ├── api_service.dart           # HTTP client
│       ├── firebase_service.dart      # FCM handling
│       └── hive_storage_service.dart  # Local storage
│
├── presentation/
│   ├── bloc/
│   │   └── auth/
│   │       ├── auth_bloc.dart
│   │       ├── auth_event.dart
│   │       └── auth_state.dart
│   └── pages/
│       ├── login_page.dart
│       ├── register_page.dart
│       └── profile_page.dart
│
└── main.dart
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd frontend/stream_sync_lite
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/core/config/app_config.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
// For Android Emulator: http://10.0.2.2:3000/api
// For iOS Simulator: http://localhost:3000/api
// For Real Device: http://YOUR_COMPUTER_IP:3000/api
```

### 3. Setup Firebase

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add Android/iOS app

#### For Android:
1. Download `google-services.json`
2. Place in `android/app/`
3. Ensure `android/build.gradle` has:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
4. Ensure `android/app/build.gradle` has:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### For iOS:
1. Download `GoogleService-Info.plist`
2. Place in `ios/Runner/`
3. Open `ios/Runner.xcworkspace` in Xcode
4. Add the plist file to the Runner target

### 4. Update Android Configuration

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    
    <application
        android:label="Stream Sync Lite"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <!-- ... -->
    </application>
</manifest>
```

### 5. Run the App

```bash
flutter run
```

## Architecture

### MVVM + BLoC Pattern

**Model** → Data models (`User`, `AuthResponse`)  
**View** → UI pages (`LoginPage`, `ProfilePage`)  
**ViewModel** → BLoC (`AuthBloc`)

### Flow

1. **View** dispatches events to **BLoC**
2. **BLoC** calls **Repository**
3. **Repository** uses **Services** (API, Storage)
4. **BLoC** emits new **State**
5. **View** rebuilds based on state

## Key Components

### Authentication Flow

```
Login → API Call → Save Tokens to Hive → Get FCM Token → 
Register FCM → Navigate to Profile
```

### Token Management

- **Access Token**: 15 minutes validity
- **Refresh Token**: 7 days validity
- Auto-refresh on 401 errors
- Stored securely in Hive

### FCM Integration

```dart
// Auto-registered on login
login() → getFCMToken() → saveFCMToken() → 
registerWithBackend()
```

## API Integration

### Endpoints Used

- `POST /auth/register` - Register user
- `POST /auth/login` - Login user
- `POST /auth/refresh` - Refresh tokens
- `GET /auth/me` - Get user profile
- `POST /fcm/register` - Register FCM token
- `DELETE /fcm/unregister` - Unregister FCM token

### HTTP Headers

```dart
Authorization: Bearer {accessToken}
Content-Type: application/json
```

## State Management

### Auth States

- `AuthInitial` - Initial state
- `AuthLoading` - Loading state
- `AuthAuthenticated` - User logged in
- `AuthUnauthenticated` - User logged out
- `AuthError` - Error occurred

### Auth Events

- `AuthLoginRequested` - Login attempt
- `AuthRegisterRequested` - Register attempt
- `AuthLogoutRequested` - Logout request
- `AuthCheckRequested` - Check auth status
- `AuthGetUserRequested` - Fetch user data

## Features Breakdown

### Login Page
- Email/password validation
- Show/hide password
- Loading state
- Error messages
- Navigate to register

### Register Page
- Name, email, password fields
- Confirm password
- Form validation
- Auto-login after registration

### Profile Page
- User avatar
- Name, email display
- Role badge
- Account information cards
- Pull-to-refresh
- Logout functionality

## Testing

### Test Login

1. Start backend: `npm run dev`
2. Run Flutter app: `flutter run`
3. Register new account or login with existing

### Test FCM

1. Login to app
2. Check backend logs for FCM token
3. Use admin account to send notification
4. Receive push notification

## Troubleshooting

### Cannot connect to backend

**Issue**: Network error  
**Solution**: Check `baseUrl` in `app_config.dart`

```dart
// Android Emulator
'http://10.0.2.2:3000/api'

// Real Device (same network)
'http://YOUR_COMPUTER_IP:3000/api'
```

### Firebase not working

**Issue**: Firebase not initialized  
**Solution**: 
1. Ensure `google-services.json` is in `android/app/`
2. Run `flutter clean && flutter pub get`
3. Rebuild app

### Hive errors

**Issue**: Hive box not initialized  
**Solution**: 
```dart
await Hive.initFlutter();
await Hive.openBox('boxName');
```

### Token expired

**Solution**: Implement auto-refresh in `ApiService`:
```dart
// On 401, call refreshToken() and retry request
```

## Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3      # State management
  equatable: ^2.0.5          # Value equality
  hive: ^2.2.3               # Local storage
  hive_flutter: ^1.1.0       # Hive Flutter support
  http: ^1.1.0               # HTTP client
  firebase_core: ^2.24.2     # Firebase core
  firebase_messaging: ^14.7.10 # FCM
  get_it: ^7.6.4             # Dependency injection
  logger: ^2.0.2+1           # Logging

dev_dependencies:
  hive_generator: ^2.0.1     # Hive code generation
  build_runner: ^2.4.7       # Code generation
```

## Best Practices

✅ Use BLoC for state management  
✅ Store sensitive data securely (Hive)  
✅ Handle loading and error states  
✅ Validate user input  
✅ Show user-friendly error messages  
✅ Auto-refresh expired tokens  
✅ Clean up resources on logout  
✅ Use dependency injection  

## Future Enhancements

- [ ] Remember me functionality
- [ ] Biometric authentication
- [ ] Profile editing
- [ ] Password reset
- [ ] Email verification
- [ ] Social login (Google, Facebook)
- [ ] Dark mode

## License

ISC

## Support

For issues or questions, check:
1. Backend is running on correct port
2. Firebase is properly configured
3. API baseUrl matches backend
4. Internet permission in AndroidManifest

Happy Coding! 🚀
