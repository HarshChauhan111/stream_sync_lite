# Stream Sync Lite - Complete Implementation Guide

## Overview
This document provides a complete implementation guide for the video streaming app with notifications, downloads, and offline sync capabilities.

## Architecture

### Storage Strategy
- **JWT Tokens**: `flutter_secure_storage` (encrypted)
- **User Data, Videos, Notifications, Downloads**: `Hive` (fast local DB)
- **Sync Queue**: `Hive` (for offline operations)

### Key Features Implemented
1. ✅ Secure JWT token storage
2. ✅ Data models for Video, Notification, Download, SyncQueue
3. 🔄 Video feed with 10 latest videos
4. 🔄 Notifications tab with badge count
5. 🔄 Downloads/Cache management
6. 🔄 Profile with test push notification
7. 🔄 Video player with resume capability
8. 🔄 Offline sync queue

## Project Structure

```
lib/
├── core/
│   ├── config/
│   │   └── app_config.dart
│   ├── di/
│   │   └── dependency_injection.dart
│   └── constants/
│       └── hive_boxes.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── video_model.dart          ✅ Created
│   │   ├── notification_model.dart   ✅ Created
│   │   ├── download_model.dart       ✅ Created
│   │   └── sync_queue_model.dart     ✅ Created
│   │
│   ├── services/
│   │   ├── secure_storage_service.dart  ✅ Created (JWT tokens)
│   │   ├── hive_service.dart
│   │   ├── api_service.dart
│   │   ├── video_service.dart
│   │   ├── notification_service.dart
│   │   ├── download_service.dart
│   │   ├── sync_service.dart
│   │   └── firebase_service.dart
│   │
│   └── repositories/
│       ├── auth_repository.dart
│       ├── video_repository.dart
│       ├── notification_repository.dart
│       └── download_repository.dart
│
├── presentation/
│   ├── bloc/
│   │   ├── auth/
│   │   ├── video/
│   │   ├── notification/
│   │   └── download/
│   │
│   ├── pages/
│   │   ├── splash_page.dart          ✅ Created
│   │   ├── login_page.dart           ✅ Created
│   │   ├── register_page.dart        ✅ Created
│   │   ├── profile_page.dart         ✅ Created
│   │   ├── home_page.dart            (Tab container)
│   │   ├── feed_page.dart            (Video list)
│   │   ├── notifications_page.dart
│   │   ├── downloads_page.dart
│   │   └── video_player_page.dart
│   │
│   └── widgets/
│       ├── video_card.dart
│       ├── notification_card.dart
│       ├── download_card.dart
│       └── custom_video_controls.dart
│
└── main.dart

```

## Setup Instructions

### 1. Install Dependencies

Run in terminal:
```bash
cd frontend/stream_sync_lite
flutter pub get
```

### 2. Generate Hive Type Adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `video_model.g.dart`
- `notification_model.g.dart`
- `download_model.g.dart`
- `sync_queue_model.g.dart`

### 3. Backend API Endpoints Needed

Add these endpoints to your Node.js backend:

#### Video Endpoints
```typescript
GET  /api/videos              // Get latest 10 videos
GET  /api/videos/:id          // Get video details
POST /api/videos/:id/progress // Save video progress
POST /api/videos/:id/favorite // Toggle favorite
```

#### Notification Endpoints
```typescript
GET    /api/notifications         // Get user notifications
POST   /api/notifications/mark-read  // Mark as read
DELETE /api/notifications/:id     // Delete notification
POST   /api/notifications/test    // Send test push (Profile page)
```

## Implementation Steps

### Step 1: Update Dependencies (✅ DONE)
- Added `flutter_secure_storage` for JWT tokens
- Added `video_player`, `chewie` for video playback
- Added `dio` for better HTTP client
- Added `cached_network_image`, `shimmer` for UI
- Added `badges` for notification count
- Added `connectivity_plus` for offline detection

### Step 2: Secure Storage for JWT (✅ DONE)
- Created `SecureStorageService` with encrypted storage
- Methods: `saveAccessToken()`, `getAccessToken()`, `saveRefreshToken()`, etc.

### Step 3: Data Models (✅ DONE)
- `VideoModel`: Complete video data with chapters, cache status, last played position
- `NotificationModel`: Notifications with read status, type, linked content
- `DownloadModel`: Download progress tracking
- `SyncQueueModel`: Offline operation queue

### Step 4: Hive Setup (NEXT)
Create `lib/data/services/hive_service.dart`:
```dart
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(VideoModelAdapter());
    Hive.registerAdapter(VideoChapterAdapter());
    Hive.registerAdapter(NotificationModelAdapter());
    Hive.registerAdapter(DownloadModelAdapter());
    Hive.registerAdapter(SyncQueueModelAdapter());
    
    // Open boxes
    await Hive.openBox<VideoModel>('videos');
    await Hive.openBox<NotificationModel>('notifications');
    await Hive.openBox<DownloadModel>('downloads');
    await Hive.openBox<SyncQueueModel>('syncQueue');
    await Hive.openBox('settings');
  }
}
```

### Step 5: Video Service
Create API calls for fetching videos, updating progress, toggling favorites.

### Step 6: Feed Page
- Display 10 latest videos in list
- Video card with thumbnail, title, channel, duration, favorite icon
- Pull-to-refresh
- Tap to open player
- Long-press/overflow menu for actions

### Step 7: Notifications Page
- Badge with unread count
- List notifications with swipe-to-delete
- Optimistic UI updates
- Queue deletions when offline

### Step 8: Downloads Page
- List cached videos
- Show download progress
- Clear cache option
- Tap to play cached video

### Step 9: Profile Page (Test Push)
- Form with Title and Body fields
- "Send Test Push" button
- Calls `/api/notifications/test` endpoint
- Shows toast on success

### Step 10: Video Player
- Full playback controls
- Resume from last position
- Save progress every 5 seconds
- Fullscreen support
- Chapters navigation
- Like/comment/share buttons

### Step 11: Offline Sync
- Queue operations when offline
- Auto-sync when connection restored
- Retry failed operations
- Clean up old queue items

## Next Commands to Run

1. **Generate Hive adapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **Update main.dart** to initialize secure storage:
```dart
// Replace HiveStorageService with SecureStorageService for auth
await SecureStorageService().init(); // No init needed, works out of box
```

3. **Create backend endpoints** for videos and notifications

4. **Test the app:**
```bash
flutter run
```

## Key Implementation Notes

### Secure Storage vs Hive
- **Secure Storage**: JWT tokens, sensitive auth data
- **Hive**: Everything else (videos, notifications, downloads, settings)

### Offline Support
- All write operations go to local Hive DB first
- Background sync service syncs to backend when online
- Sync queue ensures no data loss

### Video Progress Tracking
- Save position every 5 seconds
- Resume from last position on app restart
- Mark as "dirty" for backend sync

### Notification Handling
- FCM receives push → Save to Hive → Update badge
- Swipe delete → Remove from Hive → Queue backend delete
- Optimistic UI for instant feedback

### Cache Management
- Videos downloaded to app documents directory
- Hive stores metadata and local file paths
- Clear cache deletes files and updates Hive

## Testing Checklist

- [ ] Login/Register with JWT storage
- [ ] Feed loads 10 videos
- [ ] Video plays and resumes position
- [ ] Favorite toggle works
- [ ] Notifications show with badge
- [ ] Swipe delete works (online + offline)
- [ ] Test push from Profile works
- [ ] Downloads show progress
- [ ] Offline queue syncs when back online
- [ ] Theme toggle persists
- [ ] Logout clears secure storage

## Performance Considerations

1. **Lazy Loading**: Load videos on demand
2. **Image Caching**: Use `cached_network_image`
3. **Video Buffering**: Configure buffer size
4. **Hive Compaction**: Periodically compact boxes
5. **Sync Throttling**: Batch sync operations

## Security Notes

1. JWT tokens encrypted with `flutter_secure_storage`
2. API calls include Authorization header
3. Token refresh on 401 responses
4. Secure video URLs (signed/expiring)
5. FCM token rotation

---

**Status**: Core models and secure storage completed. Ready for service layer implementation.

**Next Task**: Run build_runner to generate Hive adapters, then implement video and notification services.
