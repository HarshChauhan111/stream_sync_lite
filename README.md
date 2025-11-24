# Stream Sync Lite

A full-stack video streaming application with real-time notifications, built with Flutter (frontend) and Node.js + TypeScript (backend).

## 📋 Overview

Stream Sync Lite is a modern video streaming platform that allows users to browse, watch, and manage video content. The application features secure authentication, push notifications, video playback with chapters, offline downloads, and a clean, intuitive user interface.

### Key Features

- 🔐 **Secure Authentication** - JWT-based auth with refresh tokens
- 📹 **Video Streaming** - Browse and watch videos with chapter support
- 🔔 **Push Notifications** - Real-time notifications via Firebase Cloud Messaging
- 📥 **Offline Downloads** - Download videos for offline viewing
- 👤 **User Profiles** - Manage user accounts and preferences
- 🎨 **Modern UI** - Material Design with responsive layouts
- 🌙 **Dark Mode Ready** - Theme support (implementation pending)
- 📱 **Cross-Platform** - Supports Android, iOS, Web, Windows, macOS, and Linux

---

## 🏗️ Architecture

### Technology Stack

#### Backend
- **Runtime**: Node.js (v16+)
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MySQL (v8+) with Sequelize ORM
- **Authentication**: JWT (jsonwebtoken) + BCrypt
- **Push Notifications**: Firebase Admin SDK
- **Validation**: Joi
- **CORS**: Enabled for cross-origin requests

#### Frontend
- **Framework**: Flutter (SDK 3.9.2+)
- **Language**: Dart
- **State Management**: flutter_bloc (BLoC pattern)
- **Local Storage**: Hive, SharedPreferences, FlutterSecureStorage
- **HTTP Client**: Dio + HTTP
- **Video Player**: video_player + chewie
- **Push Notifications**: Firebase Messaging
- **UI Components**: Material Design + Custom widgets

---

## 📁 Project Structure

```
stream_sync_lite/
├── backend/                    # Node.js + TypeScript backend
│   ├── src/
│   │   ├── config/            # Configuration files (database, firebase)
│   │   ├── controllers/       # Business logic controllers
│   │   ├── middleware/        # Authentication & validation middleware
│   │   ├── models/            # Sequelize database models
│   │   ├── routes/            # API route definitions
│   │   ├── services/          # Business services (FCM, etc.)
│   │   ├── utils/             # Utility functions
│   │   ├── validations/       # Joi validation schemas
│   │   ├── seed.ts            # Database seeder
│   │   └── index.ts           # Server entry point
│   ├── .env.example           # Environment variables template
│   ├── package.json           # Node dependencies
│   ├── tsconfig.json          # TypeScript configuration
│   └── README.md              # Backend documentation
│
├── frontend/                   # Flutter frontend
│   └── stream_sync_lite/
│       ├── lib/
│       │   ├── core/          # Core utilities & config
│       │   │   ├── config/    # App configuration (API endpoints)
│       │   │   ├── di/        # Dependency injection setup
│       │   │   └── utils/     # Utility functions
│       │   ├── data/          # Data layer
│       │   │   ├── models/    # Data models
│       │   │   ├── repositories/ # Data repositories
│       │   │   └── services/  # API services
│       │   ├── presentation/  # UI layer
│       │   │   ├── bloc/      # BLoC state management
│       │   │   ├── pages/     # Application screens
│       │   │   └── widgets/   # Reusable UI components
│       │   └── main.dart      # App entry point
│       ├── android/           # Android-specific files
│       ├── ios/               # iOS-specific files
│       ├── web/               # Web-specific files
│       ├── windows/           # Windows-specific files
│       ├── macos/             # macOS-specific files
│       ├── linux/             # Linux-specific files
│       ├── test/              # Unit & widget tests
│       ├── pubspec.yaml       # Flutter dependencies
│       └── README.md          # Frontend documentation
│
└── README.md                   # This file
```

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

#### For Backend:
- [Node.js](https://nodejs.org/) (v16 or higher)
- [MySQL](https://www.mysql.com/) (v8 or higher)
- npm or yarn package manager

#### For Frontend:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.9.2+)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Visual Studio Code](https://code.visualstudio.com/) or Android Studio

#### For Both:
- [Firebase Project](https://console.firebase.google.com/) (for push notifications)

---

## 🔧 Backend Setup

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment Variables

Create a `.env` file in the `backend` directory:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=stream_sync_lite
DB_USER=root
DB_PASSWORD=your_mysql_password

# JWT Configuration (Generate secure random strings)
JWT_ACCESS_SECRET=your_secure_access_secret_min_32_chars
JWT_REFRESH_SECRET=your_secure_refresh_secret_min_32_chars
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Firebase Configuration
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

**Generate secure JWT secrets:**
```bash
# Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Or using OpenSSL
openssl rand -hex 32
```

### 4. Setup MySQL Database

Create the database:

```sql
CREATE DATABASE stream_sync_lite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Tables will be created automatically when you start the server.

### 5. Setup Firebase (Optional but Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Go to **Project Settings** → **Service Accounts**
4. Click **"Generate New Private Key"**
5. Save the JSON file as `firebase-service-account.json` in the `backend` directory

**Note**: If you skip Firebase setup, the app will work but push notifications will be disabled.

### 6. Seed the Database (Optional)

Populate the database with sample data:

```bash
npm run seed
```

To force reset and seed:

```bash
npm run seed:force
```

### 7. Start the Backend Server

#### Development mode (with auto-reload):
```bash
npm run dev
```

#### Production mode:
```bash
npm run build
npm start
```

The backend will start at `http://localhost:3000`

---

## 📱 Frontend Setup

### 1. Navigate to Frontend Directory

```bash
cd frontend/stream_sync_lite
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

Edit `lib/core/config/app_config.dart` and update the `baseUrl` with your backend server IP:

```dart
class AppConfig {
  // Backend API Configuration
  static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
  
  // ... rest of the configuration
}
```

**For local development:**
- Use `http://localhost:3000/api` for Android emulator
- Use `http://10.0.2.2:3000/api` for Android emulator (alternative)
- Use `http://127.0.0.1:3000/api` for iOS simulator
- Use `http://YOUR_LOCAL_IP:3000/api` for physical devices

**Find your local IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

### 4. Setup Firebase for Flutter

#### a) Create Firebase Apps

In the [Firebase Console](https://console.firebase.google.com/):
1. Add an **Android app** to your Firebase project
2. Add an **iOS app** to your Firebase project (if building for iOS)

#### b) Download Configuration Files

**For Android:**
1. Download `google-services.json`
2. Place it in `frontend/stream_sync_lite/android/app/`

**For iOS:**
1. Download `GoogleService-Info.plist`
2. Place it in `frontend/stream_sync_lite/ios/Runner/`

#### c) Update Android Configuration

The `android/app/build.gradle.kts` should already have Firebase setup. Verify it includes:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase
}
```

### 5. Run the Application

#### On Android:
```bash
flutter run
```

#### On iOS:
```bash
flutter run
```

#### On Web:
```bash
flutter run -d chrome
```

#### On Windows:
```bash
flutter run -d windows
```

#### On macOS:
```bash
flutter run -d macos
```

#### On Linux:
```bash
flutter run -d linux
```

### 6. Build Release Version

#### Android APK:
```bash
flutter build apk --release
```

#### Android App Bundle:
```bash
flutter build appbundle --release
```

#### iOS:
```bash
flutter build ios --release
```

#### Web:
```bash
flutter build web --release
```

---

## 🗄️ Database Schema

### Users Table

| Field         | Type                | Description              |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment user ID   |
| name          | VARCHAR(255)        | User's full name         |
| email         | VARCHAR(255)        | Unique email address     |
| password_hash | VARCHAR(255)        | BCrypt hashed password   |
| role          | ENUM('user','admin')| User role                |
| created_at    | TIMESTAMP           | Account creation date    |
| updated_at    | TIMESTAMP           | Last update date         |

### Videos Table

| Field         | Type                | Description              |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment video ID  |
| title         | VARCHAR(255)        | Video title              |
| description   | TEXT                | Video description        |
| thumbnail_url | VARCHAR(500)        | Thumbnail image URL      |
| video_url     | VARCHAR(500)        | Video file URL           |
| duration      | VARCHAR(50)         | Video duration (e.g., "10:25") |
| views         | INT                 | View count               |
| likes         | INT                 | Like count               |
| created_at    | TIMESTAMP           | Upload date              |
| updated_at    | TIMESTAMP           | Last update date         |

### Video Chapters Table

| Field         | Type                | Description              |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment chapter ID|
| video_id      | INT (FK)            | Foreign key to videos    |
| title         | VARCHAR(255)        | Chapter title            |
| start_time    | INT                 | Start time in seconds    |
| created_at    | TIMESTAMP           | Creation date            |
| updated_at    | TIMESTAMP           | Last update date         |

### Notifications Table

| Field         | Type                | Description              |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment ID        |
| user_id       | INT (FK)            | Foreign key to users     |
| title         | VARCHAR(255)        | Notification title       |
| body          | TEXT                | Notification content     |
| type          | VARCHAR(50)         | Notification type        |
| is_read       | BOOLEAN             | Read status              |
| timestamp     | TIMESTAMP           | Notification time        |
| created_at    | TIMESTAMP           | Creation date            |
| updated_at    | TIMESTAMP           | Last update date         |

### FCM Tokens Table

| Field         | Type                | Description              |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment ID        |
| user_id       | INT (FK)            | Foreign key to users     |
| token         | TEXT                | FCM device token         |
| platform      | ENUM('android','ios','web') | Device platform |
| created_at    | TIMESTAMP           | Registration date        |
| updated_at    | TIMESTAMP           | Last update date         |

---

## 📡 API Endpoints

### Base URL
```
http://localhost:3000/api
```

### Authentication Endpoints

#### 1. Register User
```http
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### 2. Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123",
  "fcmToken": "device_fcm_token_here",  // Optional
  "platform": "android"                  // Optional
}
```

#### 3. Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "your_refresh_token"
}
```

#### 4. Get Current User
```http
GET /auth/me
Authorization: Bearer {accessToken}
```

### Video Endpoints

#### 5. Get All Videos
```http
GET /videos
Authorization: Bearer {accessToken}
```

#### 6. Get Video by ID
```http
GET /videos/:id
Authorization: Bearer {accessToken}
```

#### 7. Get Video Chapters
```http
GET /videos/:id/chapters
Authorization: Bearer {accessToken}
```

### Notification Endpoints

#### 8. Get User Notifications
```http
GET /notifications
Authorization: Bearer {accessToken}
```

#### 9. Mark Notification as Read
```http
PATCH /notifications/:id/read
Authorization: Bearer {accessToken}
```

#### 10. Delete Notification
```http
DELETE /notifications/:id
Authorization: Bearer {accessToken}
```

### FCM Endpoints

#### 11. Register FCM Token
```http
POST /fcm/register
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "token": "device_fcm_token_here",
  "platform": "android"
}
```

#### 12. Unregister FCM Token
```http
DELETE /fcm/unregister
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}
```

#### 13. Send Test Push Notification
```http
POST /fcm/test-push
Authorization: Bearer {accessToken}
```

### Health Check

#### 14. Server Health
```http
GET /health
```

---

## 🎨 Frontend Features

### Pages & Navigation

1. **Splash Screen** - Initial loading screen with authentication check
2. **Login Page** - User authentication
3. **Register Page** - New user registration
4. **Main Navigation** - Bottom navigation bar with 4 tabs:
   - **Home** - Browse videos with search and filtering
   - **Notifications** - View and manage notifications (with unread badge)
   - **Downloads** - Manage offline downloads
   - **Profile** - User account management
5. **Video Player** - Full-screen video playback with chapters
6. **Video Details** - Detailed video information with chapters list

### State Management (BLoC Pattern)

- **AuthBloc** - Authentication state management
- **VideoBloc** - Video data management
- **NotificationBloc** - Notification state management

### Local Storage

- **Hive** - For caching video data
- **SharedPreferences** - For user preferences
- **FlutterSecureStorage** - For secure token storage

### UI Components

- Video cards with thumbnails
- Chapter timeline navigation
- Notification badges
- Shimmer loading effects
- Pull-to-refresh
- Overflow menus
- Custom error screens

---

## 🔒 Security Features

### Backend Security

1. **Password Hashing** - BCrypt with 10 salt rounds
2. **JWT Tokens** - Secure access and refresh tokens
3. **Token Expiry** - Access token: 15 minutes, Refresh token: 7 days
4. **Input Validation** - Joi schema validation on all inputs
5. **CORS Configuration** - Controlled cross-origin access
6. **SQL Injection Protection** - Sequelize ORM parameterized queries
7. **Environment Variables** - Sensitive data in `.env` files

### Frontend Security

1. **Secure Storage** - FlutterSecureStorage for tokens
2. **Token Refresh** - Automatic token refresh before expiry
3. **HTTPS Ready** - Supports secure connections
4. **Input Validation** - Form validation on all user inputs

---

## 🧪 Testing

### Backend Testing

```bash
cd backend
npm test
```

### Frontend Testing

```bash
cd frontend/stream_sync_lite
flutter test
```

### Manual Testing

Use tools like:
- **Postman** - API testing
- **Thunder Client** (VS Code extension) - API testing
- **Flutter DevTools** - UI and performance debugging

---

## 📦 Deployment

### Backend Deployment

#### Prerequisites for Production:
1. Update `.env` with production values
2. Set `NODE_ENV=production`
3. Use HTTPS (configure reverse proxy like Nginx)
4. Enable rate limiting
5. Configure CORS for specific origins

#### Deploy to Cloud:
- **AWS EC2** - Traditional VM deployment
- **Heroku** - Easy platform deployment
- **DigitalOcean** - Droplet deployment
- **Railway** - Modern deployment platform
- **Render** - Simple cloud deployment

#### Build and Run:
```bash
npm run build
NODE_ENV=production node dist/index.js
```

### Frontend Deployment

#### Android Play Store:
```bash
flutter build appbundle --release
```

#### iOS App Store:
```bash
flutter build ios --release
```

#### Web Hosting:
```bash
flutter build web --release
# Deploy the build/web directory to hosting service
```

#### Desktop Distribution:
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## 🔧 Configuration Files

### Backend Configuration

**`.env`** - Environment variables
```env
PORT=3000
DB_HOST=localhost
DB_NAME=stream_sync_lite
JWT_ACCESS_SECRET=your_secret
JWT_REFRESH_SECRET=your_secret
```

**`tsconfig.json`** - TypeScript compiler options
**`package.json`** - Node dependencies and scripts

### Frontend Configuration

**`pubspec.yaml`** - Flutter dependencies
**`lib/core/config/app_config.dart`** - App configuration
**`android/app/build.gradle.kts`** - Android build configuration
**`ios/Runner/Info.plist`** - iOS configuration

---

## 🐛 Troubleshooting

### Common Backend Issues

**Database Connection Failed:**
- Verify MySQL is running
- Check database credentials in `.env`
- Ensure database exists

**Port Already in Use:**
- Change `PORT` in `.env`
- Or kill the process: `npx kill-port 3000`

**Firebase Errors:**
- Verify `firebase-service-account.json` exists
- Check file path in `.env`

### Common Frontend Issues

**API Connection Failed:**
- Verify backend is running
- Check `baseUrl` in `app_config.dart`
- Use correct IP address for physical devices

**Build Errors:**
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter SDK version

**Firebase Push Notifications Not Working:**
- Verify `google-services.json` (Android) is in place
- Verify `GoogleService-Info.plist` (iOS) is in place
- Check Firebase configuration in console

**Video Playback Issues:**
- Check video URL accessibility
- Verify network permissions in manifest files
- Test with different video formats

---

## 📚 Additional Resources

### Documentation

- [Backend API Documentation](backend/API_DOCUMENTATION.md)
- [Backend Setup Guide](backend/SETUP.md)
- [Frontend README](frontend/stream_sync_lite/README.md)

### Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Pattern Guide](https://bloclibrary.dev/)
- [Express.js Guide](https://expressjs.com/)
- [Sequelize Documentation](https://sequelize.org/)
- [Firebase Documentation](https://firebase.google.com/docs)

---

## 🤝 Contributing

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Code Style

**Backend:**
- Follow TypeScript best practices
- Use ESLint for linting
- Write meaningful comments

**Frontend:**
- Follow Dart style guide
- Use `flutter analyze` for linting
- Write widget and unit tests

---

## 📄 License

This project is licensed under the ISC License.

---

## 👥 Team & Support

**Project**: Stream Sync Lite  
**Version**: 1.0.0  
**Last Updated**: November 24, 2025

For issues, questions, or contributions, please contact the development team or open an issue on the repository.

---

## 🎯 Roadmap

### Completed Features ✅
- User authentication with JWT
- Video browsing and playback
- Push notifications
- Tab-based navigation
- Chapter support for videos
- Notification management
- Offline downloads UI

### Upcoming Features 🚧
- Dark mode theme
- Actual video download/caching logic
- Video upload functionality
- User comments and ratings
- Video search and filters
- Playlist management
- Social sharing
- Analytics dashboard
- Video recommendations
- Live streaming support

---

## 📊 Performance Considerations

### Backend Optimization
- Database query optimization with indexes
- Connection pooling for MySQL
- Caching strategies (Redis recommended)
- Rate limiting to prevent abuse
- Gzip compression for responses

### Frontend Optimization
- Image caching with `cached_network_image`
- Lazy loading for video lists
- Optimized video player buffering
- Efficient state management with BLoC
- Code splitting for web builds

---

**Happy Coding! 🚀**
