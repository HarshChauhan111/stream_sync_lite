# API Documentation - Stream Sync Lite Backend

## Base URL
```
http://localhost:3000/api
```

## Authentication
Most endpoints require JWT authentication. Include the access token in the Authorization header:
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

---

## Authentication Endpoints

### 1. Register New User

**Endpoint:** `POST /auth/register`  
**Access:** Public  
**Description:** Create a new user account

**Request Body:**
```json
{
  "name": "string (required, min 2 chars)",
  "email": "string (required, valid email)",
  "password": "string (required, min 6 chars)"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "created_at": "2025-11-23T10:30:00.000Z",
      "updated_at": "2025-11-23T10:30:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input (validation failed)
- `409 Conflict`: Email already registered
- `500 Internal Server Error`: Server error

---

### 2. Login

**Endpoint:** `POST /auth/login`  
**Access:** Public  
**Description:** Login with credentials and optionally register FCM token

**Request Body:**
```json
{
  "email": "string (required, valid email)",
  "password": "string (required)",
  "fcmToken": "string (optional)",
  "platform": "string (optional: 'android', 'ios', 'web')"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "created_at": "2025-11-23T10:30:00.000Z",
      "updated_at": "2025-11-23T10:30:00.000Z"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Invalid email or password
- `500 Internal Server Error`: Server error

---

### 3. Refresh Access Token

**Endpoint:** `POST /auth/refresh`  
**Access:** Public  
**Description:** Get new access and refresh tokens using refresh token

**Request Body:**
```json
{
  "refreshToken": "string (required)"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Tokens refreshed successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**
- `400 Bad Request`: Missing refresh token
- `401 Unauthorized`: Invalid or expired refresh token
- `500 Internal Server Error`: Server error

---

### 4. Get Current User Profile

**Endpoint:** `GET /auth/me`  
**Access:** Private (Requires Authentication)  
**Description:** Get logged-in user's profile information

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user",
      "created_at": "2025-11-23T10:30:00.000Z",
      "updated_at": "2025-11-23T10:30:00.000Z"
    }
  }
}
```

**Error Responses:**
- `401 Unauthorized`: Missing or invalid token
- `404 Not Found`: User not found
- `500 Internal Server Error`: Server error

---

## FCM (Firebase Cloud Messaging) Endpoints

### 5. Register FCM Token

**Endpoint:** `POST /fcm/register`  
**Access:** Private (Requires Authentication)  
**Description:** Register device FCM token for push notifications

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Request Body:**
```json
{
  "token": "string (required, FCM device token)",
  "platform": "string (required: 'android', 'ios', 'web')"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "FCM token registered successfully"
}
```

**Error Responses:**
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Missing or invalid token
- `500 Internal Server Error`: Server error

---

### 6. Unregister FCM Token

**Endpoint:** `DELETE /fcm/unregister`  
**Access:** Private (Requires Authentication)  
**Description:** Remove FCM token (used during logout)

**Headers:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Request Body:**
```json
{
  "token": "string (required, FCM device token)"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "FCM token unregistered successfully"
}
```

**Error Responses:**
- `400 Bad Request`: Missing token
- `401 Unauthorized`: Missing or invalid token
- `500 Internal Server Error`: Server error

---

### 7. Send Push Notification

**Endpoint:** `POST /fcm/send`  
**Access:** Private (Requires Admin Role)  
**Description:** Send push notification to a user (admin only)

**Headers:**
```
Authorization: Bearer YOUR_ADMIN_ACCESS_TOKEN
```

**Request Body:**
```json
{
  "userId": "number (required)",
  "title": "string (required)",
  "body": "string (required)",
  "data": {
    "key": "value (optional custom data)"
  }
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Notification sent successfully",
  "data": {
    "successCount": 2,
    "failureCount": 0
  }
}
```

**Error Responses:**
- `400 Bad Request`: Missing required fields
- `401 Unauthorized`: Missing or invalid token
- `403 Forbidden`: Not admin user
- `404 Not Found`: No FCM tokens found for user
- `503 Service Unavailable`: Firebase not initialized
- `500 Internal Server Error`: Server error

---

## Utility Endpoints

### 8. Health Check

**Endpoint:** `GET /health`  
**Access:** Public  
**Description:** Check if server is running

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-11-23T10:30:00.000Z"
}
```

---

## Error Response Format

All error responses follow this format:

```json
{
  "success": false,
  "message": "Error description"
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid input/validation failed |
| 401 | Unauthorized - Authentication required or token invalid |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists (e.g., duplicate email) |
| 500 | Internal Server Error - Server-side error |
| 503 | Service Unavailable - Service temporarily unavailable |

---

## JWT Token Information

### Access Token
- **Validity:** 15 minutes
- **Usage:** Include in Authorization header for all protected endpoints
- **Format:** `Bearer YOUR_ACCESS_TOKEN`

### Refresh Token
- **Validity:** 7 days
- **Usage:** Use to get new access token when it expires
- **Endpoint:** `POST /auth/refresh`

### Token Payload
```json
{
  "userId": 1,
  "email": "user@example.com",
  "role": "user",
  "iat": 1700000000,
  "exp": 1700003600
}
```

---

## User Roles

### User (Default)
- Can access own profile
- Can manage own FCM tokens
- Can use app features

### Admin
- All user permissions
- Can send push notifications to any user
- Can access admin-only endpoints

---

## Rate Limiting

Currently no rate limiting is implemented. For production:
- Recommended: 100 requests per 15 minutes per IP
- Use express-rate-limit middleware

---

## CORS

CORS is enabled for all origins in development. For production, configure specific origins in `src/index.ts`:

```typescript
app.use(cors({
  origin: ['https://yourapp.com'],
  credentials: true
}));
```

---

## Example Workflow

### 1. User Registration & Login Flow
```
1. POST /auth/register → Get tokens
2. Store tokens securely
3. Use accessToken for API calls
4. When accessToken expires → POST /auth/refresh
5. Update stored tokens
```

### 2. FCM Token Management
```
1. User logs in → POST /auth/login with fcmToken
2. OR after login → POST /fcm/register
3. On logout → DELETE /fcm/unregister
```

### 3. Admin Send Notification
```
1. Admin logs in with admin account
2. POST /fcm/send with userId and notification data
3. All user's devices receive notification
```

---

## Testing with cURL

### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

### Get Profile (with token)
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Security Best Practices

1. **Always use HTTPS in production**
2. **Store JWT secrets securely** (use environment variables)
3. **Never expose sensitive data** in API responses
4. **Validate all inputs** (already implemented with Joi)
5. **Use strong passwords** (minimum 6 characters, recommend 8+)
6. **Implement rate limiting** for production
7. **Regular security audits** and dependency updates
8. **Log security events** (login attempts, failed auth, etc.)

---

## Need Help?

- Check README.md for setup instructions
- Review SETUP.md for step-by-step guide
- Import postman-collection.json for easy testing
- Check server logs for detailed error messages
