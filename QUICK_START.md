# Stream Sync Lite - Quick Start Guide

## Backend Setup ✅ COMPLETE

All backend endpoints are ready! Here's what was created:

### Database Models
- ✅ `Video` - Store video metadata
- ✅ `Notification` - Store user notifications  
- ✅ `VideoProgress` - Track watch history and favorites

### API Endpoints
- ✅ `/api/videos` - Get 10 latest videos
- ✅ `/api/videos/:id` - Get video details
- ✅ `/api/videos/:id/progress` - Save playback position
- ✅ `/api/videos/:id/favorite` - Toggle favorite
- ✅ `/api/videos/favorites` - Get favorites
- ✅ `/api/notifications` - Get notifications with unread count
- ✅ `/api/notifications/:id/read` - Mark as read
- ✅ `/api/notifications/:id` - Delete notification
- ✅ `/api/notifications/test` - Send test push (for Profile page)
- ✅ `/api/notifications/mark-all-read` - Mark all as read

### Features
- ✅ User progress tracking (resume video from last position)
- ✅ Favorites system
- ✅ Push notifications with FCM
- ✅ Notification management (read, delete)
- ✅ Test push from Profile page
- ✅ Seed script with 10 sample videos

---

## Start Backend Server

```bash
cd backend

# Seed sample videos (do this once)
npm run seed

# Start server
npm run dev
```

Server will run on: `http://192.168.1.6:3000`

---

## Flutter Setup (Next Steps)

The Flutter app structure is ready with:
- ✅ Secure storage for JWT tokens
- ✅ Data models (Video, Notification, Download, SyncQueue)
- ✅ Updated dependencies

### To Fix Build Error

Run these commands:

```bash
cd frontend/stream_sync_lite

# Clean everything
flutter clean
rm -rf .dart_tool

# Get dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build --delete-conflicting-outputs
```

If build_runner still fails, it's okay! We can skip Hive code generation and use JSON serialization instead for now.

---

## What Flutter Needs (View Layer Only)

Since all business logic is in backend, Flutter just needs:

### 1. **Home Page (Feed Tab)**
- Display list of videos from `/api/videos`
- Show thumbnail, title, channel, duration, favorite icon
- Pull-to-refresh to reload
- Tap video → open player
- Long press → show menu (favorite, share)

### 2. **Notifications Tab**
- Display notifications from `/api/notifications`
- Badge showing unread count
- Swipe left to delete → `DELETE /api/notifications/:id`
- Tap notification → mark as read + navigate to content
- Pull-to-refresh

### 3. **Downloads Tab**
- Show cached videos (stored in Hive locally)
- Display download progress
- Tap to play cached video
- Clear cache button

### 4. **Profile Page**
- User info (name, email, role)
- **Test Push section:**
  - Title input field
  - Body input field
  - "Send Test Push" button → `POST /api/notifications/test`
  - Show toast/snackbar on success
- Logout button
- Theme toggle

### 5. **Video Player Page**
- Use `video_player` + `chewie` packages
- Play video from URL
- Resume from last position (get from `/api/videos/:id`)
- Save progress every 5 seconds → `POST /api/videos/:id/progress`
- Fullscreen button
- Like/favorite button → `POST /api/videos/:id/favorite`
- Share button

---

## API Usage Examples

### Get Videos
```dart
final response = await dio.get(
  'http://192.168.1.6:3000/api/videos',
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
List<VideoModel> videos = (response.data['data'] as List)
    .map((json) => VideoModel.fromJson(json))
    .toList();
```

### Save Video Progress
```dart
await dio.post(
  'http://192.168.1.6:3000/api/videos/$videoId/progress',
  data: {'lastPlayedPosition': position},
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
```

### Get Notifications with Unread Count
```dart
final response = await dio.get(
  'http://192.168.1.6:3000/api/notifications',
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
int unreadCount = response.data['unreadCount'];
List<NotificationModel> notifications = (response.data['data'] as List)
    .map((json) => NotificationModel.fromJson(json))
    .toList();
```

### Delete Notification (Swipe Action)
```dart
await dio.delete(
  'http://192.168.1.6:3000/api/notifications/$notificationId',
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
```

### Send Test Push (Profile Page)
```dart
await dio.post(
  'http://192.168.1.6:3000/api/notifications/test',
  data: {
    'title': titleController.text,
    'body': bodyController.text,
  },
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
// Show success toast
```

### Toggle Favorite
```dart
await dio.post(
  'http://192.168.1.6:3000/api/videos/$videoId/favorite',
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
```

---

## Firebase Cloud Messaging Setup

When FCM push arrives, the Flutter app should:
1. Save notification to local Hive database
2. Update notification badge count
3. Show notification banner
4. When tapped, navigate to linked content

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Save to Hive
  final notification = NotificationModel.fromJson({
    'id': DateTime.now().millisecondsSinceEpoch,
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'type': message.data['type'] ?? 'other',
    'linkedContentId': message.data['linkedContentId'],
    'isRead': false,
  });
  
  // Store in Hive
  await notificationBox.add(notification);
  
  // Update badge
  updateBadgeCount();
  
  // Show local notification
  showLocalNotification(notification);
});
```

---

## Architecture Summary

```
┌─────────────────────────────────────────┐
│           FLUTTER (View Only)            │
├─────────────────────────────────────────┤
│  - Display data from API                 │
│  - Handle user interactions              │
│  - Send requests to backend              │
│  - Cache data locally (Hive)             │
│  - Secure JWT storage                    │
└──────────────┬──────────────────────────┘
               │ HTTP Requests
               │ (dio package)
               ▼
┌─────────────────────────────────────────┐
│        NODE.JS BACKEND (Logic)           │
├─────────────────────────────────────────┤
│  - Authentication & Authorization        │
│  - Business logic                        │
│  - Data validation                       │
│  - Database operations (MySQL)           │
│  - FCM push notifications                │
│  - Video progress tracking               │
│  - Favorites management                  │
└─────────────────────────────────────────┘
```

---

## Testing Workflow

1. ✅ Start backend: `npm run dev`
2. ✅ Seed videos: `npm run seed`
3. ✅ Test endpoints with Postman/curl
4. 🔄 Build Flutter UI pages
5. 🔄 Connect to backend APIs
6. 🔄 Test on real device
7. 🔄 Test push notifications
8. 🔄 Test offline sync

---

## Current Status

### ✅ Backend (100%)
- All models created
- All API endpoints implemented
- FCM integration working
- Sample data seeding ready

### 🔄 Flutter (30%)
- Dependencies added
- Secure storage configured
- Data models created
- **Still needed**: UI pages, API service layer, BLoC/state management

---

## Next: Build Flutter UI

Would you like me to continue creating the Flutter UI pages? I'll build:
1. Feed page with video list
2. Notifications page with swipe-to-delete
3. Downloads page
4. Updated Profile page with Test Push UI
5. Video player with controls and progress saving

All pages will call the backend APIs - no business logic in Flutter!
