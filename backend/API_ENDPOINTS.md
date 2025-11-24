# Backend API Endpoints

## Base URL
```
http://192.168.1.6:3000/api
```

## Authentication
Most endpoints require JWT authentication. Include the access token in the Authorization header:
```
Authorization: Bearer <access_token>
```

---

## Video Endpoints

### GET /videos
Get latest videos (10 by default)

**Query Parameters:**
- `limit` (optional): Number of videos to return (default: 10)
- `offset` (optional): Pagination offset (default: 0)

**Headers:**
- `Authorization` (optional): If provided, returns user-specific data (favorites, progress)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Introduction to Flutter",
      "channelName": "Flutter Academy",
      "thumbnailUrl": "https://...",
      "videoUrl": "https://...",
      "duration": "9:56",
      "publishedDate": "2024-01-15T00:00:00.000Z",
      "description": "...",
      "viewCount": 15420,
      "likeCount": 1250,
      "isFavorite": false,
      "lastPlayedPosition": 0
    }
  ],
  "total": 10
}
```

---

### GET /videos/:id
Get single video details

**Parameters:**
- `id`: Video ID

**Headers:**
- `Authorization` (optional): If provided, returns user-specific progress

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Introduction to Flutter",
    "channelName": "Flutter Academy",
    "thumbnailUrl": "https://...",
    "videoUrl": "https://...",
    "duration": "9:56",
    "publishedDate": "2024-01-15T00:00:00.000Z",
    "description": "...",
    "viewCount": 15420,
    "likeCount": 1250,
    "isFavorite": true,
    "lastPlayedPosition": 125
  }
}
```

---

### POST /videos/:id/progress
Save video playback progress

**Headers:**
- `Authorization`: Required

**Parameters:**
- `id`: Video ID

**Body:**
```json
{
  "lastPlayedPosition": 125
}
```

**Response:**
```json
{
  "success": true,
  "message": "Progress updated",
  "data": {
    "id": 1,
    "userId": 1,
    "videoId": 1,
    "lastPlayedPosition": 125,
    "isFavorite": false
  }
}
```

---

### POST /videos/:id/favorite
Toggle video favorite status

**Headers:**
- `Authorization`: Required

**Parameters:**
- `id`: Video ID

**Response:**
```json
{
  "success": true,
  "message": "Added to favorites",
  "data": {
    "isFavorite": true
  }
}
```

---

### GET /videos/favorites
Get user's favorite videos

**Headers:**
- `Authorization`: Required

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Introduction to Flutter",
      "channelName": "Flutter Academy",
      "thumbnailUrl": "https://...",
      "videoUrl": "https://...",
      "duration": "9:56",
      "isFavorite": true,
      "lastPlayedPosition": 125
    }
  ]
}
```

---

## Notification Endpoints

### GET /notifications
Get user notifications

**Headers:**
- `Authorization`: Required

**Query Parameters:**
- `limit` (optional): Number of notifications (default: 50)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "userId": 1,
      "title": "New Video Available",
      "body": "Check out our latest tutorial on Flutter",
      "preview": "Check out our latest tutorial...",
      "type": "video",
      "linkedContentId": "5",
      "thumbnailUrl": "https://...",
      "isRead": false,
      "createdAt": "2024-03-15T10:30:00.000Z"
    }
  ],
  "unreadCount": 5,
  "total": 25
}
```

---

### POST /notifications/:id/read
Mark notification as read

**Headers:**
- `Authorization`: Required

**Parameters:**
- `id`: Notification ID

**Response:**
```json
{
  "success": true,
  "message": "Notification marked as read",
  "data": {
    "id": 1,
    "isRead": true
  }
}
```

---

### POST /notifications/mark-all-read
Mark all notifications as read

**Headers:**
- `Authorization`: Required

**Response:**
```json
{
  "success": true,
  "message": "All notifications marked as read"
}
```

---

### DELETE /notifications/:id
Delete notification

**Headers:**
- `Authorization`: Required

**Parameters:**
- `id`: Notification ID

**Response:**
```json
{
  "success": true,
  "message": "Notification deleted"
}
```

---

### POST /notifications/test
Send test push notification to current user

**Headers:**
- `Authorization`: Required

**Body:**
```json
{
  "title": "Test Notification",
  "body": "This is a test push notification"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Test push notification sent successfully",
  "data": {
    "id": 15,
    "userId": 1,
    "title": "Test Notification",
    "body": "This is a test push notification",
    "type": "system",
    "isRead": false
  }
}
```

---

### POST /notifications (Admin Only)
Create notification for any user

**Headers:**
- `Authorization`: Required (Admin role)

**Body:**
```json
{
  "userId": 1,
  "title": "Important Update",
  "body": "Please update your app to the latest version",
  "type": "system",
  "linkedContentId": null,
  "thumbnailUrl": null,
  "data": {}
}
```

**Response:**
```json
{
  "success": true,
  "message": "Notification created",
  "data": {
    "id": 16,
    "userId": 1,
    "title": "Important Update",
    "body": "Please update your app...",
    "type": "system",
    "isRead": false
  }
}
```

---

## Setup Instructions

### 1. Install Dependencies
Already done, but if needed:
```bash
cd backend
npm install
```

### 2. Configure Database
Make sure MySQL is running and `.env` is configured:
```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=stream_sync_lite
DB_USER=root
DB_PASSWORD=your_password
```

### 3. Seed Sample Videos
```bash
npm run seed
```

This will create 10 sample videos with real video URLs from Google's test bucket.

### 4. Start Backend Server
```bash
npm run dev
```

Server will start on `http://localhost:3000`

---

## Testing the API

### 1. Register/Login
```bash
# Register
curl -X POST http://192.168.1.6:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://192.168.1.6:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 2. Get Videos
```bash
# Without auth
curl http://192.168.1.6:3000/api/videos

# With auth (gets personalized data)
curl http://192.168.1.6:3000/api/videos \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 3. Save Video Progress
```bash
curl -X POST http://192.168.1.6:3000/api/videos/1/progress \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"lastPlayedPosition": 125}'
```

### 4. Toggle Favorite
```bash
curl -X POST http://192.168.1.6:3000/api/videos/1/favorite \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 5. Get Notifications
```bash
curl http://192.168.1.6:3000/api/notifications \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 6. Send Test Push
```bash
curl -X POST http://192.168.1.6:3000/api/notifications/test \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Push",
    "body": "This is a test notification from Profile page"
  }'
```

### 7. Delete Notification
```bash
curl -X DELETE http://192.168.1.6:3000/api/notifications/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Database Tables

### videos
- `id` - Primary key
- `title` - Video title
- `channelName` - Channel name
- `thumbnailUrl` - Thumbnail image URL
- `videoUrl` - Video stream URL
- `duration` - Video duration (e.g., "9:56")
- `publishedDate` - Publication date
- `description` - Video description
- `viewCount` - Number of views
- `likeCount` - Number of likes
- `createdAt` - Record creation timestamp
- `updatedAt` - Record update timestamp

### notifications
- `id` - Primary key
- `userId` - Foreign key to users
- `title` - Notification title
- `body` - Notification body
- `preview` - Short preview text
- `type` - Type (video, comment, like, system, other)
- `linkedContentId` - Related content ID
- `thumbnailUrl` - Optional thumbnail
- `data` - JSON data
- `isRead` - Read status
- `createdAt` - Creation timestamp
- `updatedAt` - Update timestamp

### video_progress
- `id` - Primary key
- `userId` - Foreign key to users
- `videoId` - Foreign key to videos
- `lastPlayedPosition` - Position in seconds
- `isFavorite` - Favorite status
- `createdAt` - Creation timestamp
- `updatedAt` - Update timestamp
- Unique constraint on (userId, videoId)

---

## Error Responses

All error responses follow this format:
```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error
