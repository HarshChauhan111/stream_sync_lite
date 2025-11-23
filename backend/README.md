# Stream Sync Lite Backend

A robust Node.js + TypeScript backend API with JWT authentication, BCrypt password hashing, Firebase Cloud Messaging (FCM) integration, and MySQL database using Sequelize ORM.

## Features

- ✅ User Authentication (Register, Login, Refresh Token)
- ✅ JWT Access Token (15 minutes) + Refresh Token (7 days)
- ✅ BCrypt Password Hashing
- ✅ Joi Request Validation
- ✅ MySQL Database with Sequelize ORM
- ✅ Firebase Cloud Messaging (FCM) Integration
- ✅ Role-based Access Control (User/Admin)
- ✅ TypeScript for Type Safety
- ✅ RESTful API Design

## Tech Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: MySQL
- **ORM**: Sequelize
- **Authentication**: JWT (jsonwebtoken)
- **Password Hashing**: BCrypt
- **Validation**: Joi
- **Push Notifications**: Firebase Admin SDK
- **CORS**: Enabled

## Prerequisites

Before running this project, make sure you have:

- Node.js (v16 or higher)
- MySQL (v8 or higher)
- Firebase Project (for FCM)

## Installation

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Setup Environment Variables

Create a `.env` file in the backend directory:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

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

### 3. Setup MySQL Database

Create the database:

```sql
CREATE DATABASE stream_sync_lite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

The tables will be created automatically when you start the server.

### 4. Setup Firebase (Optional but Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file as `firebase-service-account.json` in the backend directory

**Note**: If you don't setup Firebase, the app will still work but FCM features will be disabled.

## Running the Application

### Development Mode (with auto-reload)

```bash
npm run dev
```

### Build TypeScript

```bash
npm run build
```

### Production Mode

```bash
npm start
```

The server will start on `http://localhost:3000`

## Database Schema

### Users Table

| Field         | Type                | Notes                    |
|---------------|---------------------|--------------------------|
| id            | INT (PK)            | Auto-increment           |
| name          | VARCHAR(255)        | Required                 |
| email         | VARCHAR(255)        | Unique, required         |
| password_hash | VARCHAR(255)        | BCrypt hashed            |
| role          | ENUM('user','admin')| Default: 'user'          |
| created_at    | TIMESTAMP           | Auto-generated           |
| updated_at    | TIMESTAMP           | Auto-updated             |

### FCM Tokens Table

| Field      | Type                           | Notes                    |
|------------|--------------------------------|--------------------------|
| id         | INT (PK)                       | Auto-increment           |
| user_id    | INT (FK → users.id)            | CASCADE on delete        |
| token      | TEXT                           | FCM device token         |
| platform   | ENUM('android','ios','web')    | Device platform          |
| created_at | TIMESTAMP                      | Auto-generated           |
| updated_at | TIMESTAMP                      | Auto-updated             |

## API Endpoints

### Base URL: `http://localhost:3000/api`

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

Response: 201 Created
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
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
  "platform": "android"                  // Optional: android, ios, web
}

Response: 200 OK
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user"
    },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

#### 3. Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}

Response: 200 OK
{
  "success": true,
  "message": "Tokens refreshed successfully",
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc..."
  }
}
```

#### 4. Get Current User Profile
```http
GET /auth/me
Authorization: Bearer {accessToken}

Response: 200 OK
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user"
    }
  }
}
```

### FCM Endpoints

#### 5. Register FCM Token
```http
POST /fcm/register
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "token": "device_fcm_token_here",
  "platform": "android"
}

Response: 200 OK
{
  "success": true,
  "message": "FCM token registered successfully"
}
```

#### 6. Unregister FCM Token (Logout)
```http
DELETE /fcm/unregister
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "token": "device_fcm_token_here"
}

Response: 200 OK
{
  "success": true,
  "message": "FCM token unregistered successfully"
}
```

#### 7. Send Notification (Admin Only)
```http
POST /fcm/send
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "userId": 1,
  "title": "New Notification",
  "body": "You have a new message",
  "data": {
    "type": "message",
    "id": "123"
  }
}

Response: 200 OK
{
  "success": true,
  "message": "Notification sent successfully",
  "data": {
    "successCount": 1,
    "failureCount": 0
  }
}
```

### Health Check

```http
GET /api/health

Response: 200 OK
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2025-11-23T10:30:00.000Z"
}
```

## Authentication Flow

### 1. Registration/Login
- Client sends credentials
- Server validates using Joi
- Password is hashed with BCrypt
- JWT tokens are generated (access + refresh)
- FCM token saved (if provided)
- Tokens returned to client

### 2. Protected API Calls
- Client includes: `Authorization: Bearer {accessToken}`
- Middleware verifies token
- If valid: request proceeds
- If expired: client should refresh

### 3. Token Refresh
- When access token expires
- Client sends refresh token to `/auth/refresh`
- Server validates refresh token
- New token pair generated
- Client updates stored tokens

### 4. Logout
- Client calls `/fcm/unregister` with FCM token
- Client deletes stored tokens locally

## Error Responses

All errors follow this format:

```json
{
  "success": false,
  "message": "Error description"
}
```

### Common HTTP Status Codes

- `200 OK` - Success
- `201 Created` - Resource created
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid/expired token
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `409 Conflict` - Duplicate email
- `500 Internal Server Error` - Server error

## Security Best Practices

1. **Passwords**: Hashed with BCrypt (10 salt rounds)
2. **JWT Secrets**: Use strong random strings (min 32 characters)
3. **Token Expiry**: Access token expires in 15 minutes
4. **HTTPS**: Use HTTPS in production
5. **Environment Variables**: Never commit `.env` or `firebase-service-account.json`
6. **CORS**: Configure allowed origins in production
7. **Rate Limiting**: Recommended for production

## Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── index.ts          # Configuration loader
│   │   ├── database.ts       # Sequelize setup
│   │   └── firebase.ts       # Firebase Admin SDK
│   ├── models/
│   │   ├── User.ts           # User model
│   │   ├── FCMToken.ts       # FCM Token model
│   │   └── index.ts          # Model associations
│   ├── controllers/
│   │   └── auth.controller.ts # Auth logic
│   ├── services/
│   │   └── fcm.service.ts    # FCM operations
│   ├── middleware/
│   │   └── auth.middleware.ts # JWT verification
│   ├── validations/
│   │   └── auth.validation.ts # Joi schemas
│   ├── utils/
│   │   └── jwt.ts            # JWT utilities
│   ├── routes/
│   │   ├── auth.routes.ts    # Auth routes
│   │   ├── fcm.routes.ts     # FCM routes
│   │   └── index.ts          # Route aggregator
│   └── index.ts              # Server entry point
├── package.json
├── tsconfig.json
├── .env.example
├── .gitignore
└── README.md
```

## Development Tips

### Create Admin User

To create an admin user, manually update the database:

```sql
UPDATE users SET role = 'admin' WHERE email = 'admin@example.com';
```

### Testing with Postman/Thunder Client

1. Register a user
2. Save the `accessToken` and `refreshToken`
3. Use `accessToken` in Authorization header for protected routes
4. When token expires, use refresh endpoint with `refreshToken`

### Generating Secure JWT Secrets

```bash
# Option 1: Using Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Option 2: Using OpenSSL
openssl rand -hex 32
```

## Troubleshooting

### Database Connection Failed
- Verify MySQL is running
- Check database credentials in `.env`
- Ensure database exists

### Firebase Errors
- Verify `firebase-service-account.json` exists
- Check file path in `.env`
- App works without Firebase (FCM disabled)

### TypeScript Errors
- Run `npm install` to ensure all dependencies are installed
- Check `tsconfig.json` configuration

### Port Already in Use
- Change `PORT` in `.env`
- Or kill the process using the port

## License

ISC

## Support

For issues or questions, please contact the development team.
