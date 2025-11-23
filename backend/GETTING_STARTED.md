# 🚀 Stream Sync Lite Backend - Complete Setup

## ✅ What Has Been Created

A complete **Node.js + TypeScript** backend with:

### 🔐 Authentication Features
- ✅ User Registration with email validation
- ✅ User Login with JWT tokens
- ✅ BCrypt password hashing (10 salt rounds)
- ✅ JWT Access Token (15 minutes validity)
- ✅ JWT Refresh Token (7 days validity)
- ✅ Token refresh mechanism
- ✅ Role-based access (user/admin)
- ✅ Protected routes with middleware

### 📱 FCM Integration
- ✅ FCM token registration after login
- ✅ FCM token storage in database
- ✅ FCM token management (register/unregister)
- ✅ Push notification sending (admin only)
- ✅ Multi-device support (android/ios/web)

### 🛡️ Security & Validation
- ✅ Joi validation for all inputs
- ✅ Password hashing with BCrypt
- ✅ JWT token verification middleware
- ✅ Admin-only route protection
- ✅ Email uniqueness validation
- ✅ Secure error handling

### 💾 Database
- ✅ MySQL with Sequelize ORM
- ✅ Users table with role support
- ✅ FCM Tokens table
- ✅ Proper relationships and foreign keys
- ✅ Automatic table creation

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/
│   │   ├── index.ts              # Configuration loader
│   │   ├── database.ts           # Sequelize setup & connection
│   │   └── firebase.ts           # Firebase Admin SDK setup
│   │
│   ├── models/
│   │   ├── User.ts               # User model with bcrypt methods
│   │   ├── FCMToken.ts           # FCM Token model
│   │   └── index.ts              # Model associations
│   │
│   ├── controllers/
│   │   └── auth.controller.ts    # Register, Login, Refresh, Me
│   │
│   ├── services/
│   │   └── fcm.service.ts        # FCM token & notification logic
│   │
│   ├── middleware/
│   │   └── auth.middleware.ts    # JWT auth & admin middleware
│   │
│   ├── validations/
│   │   └── auth.validation.ts    # Joi schemas for validation
│   │
│   ├── utils/
│   │   └── jwt.ts                # JWT generation & verification
│   │
│   ├── routes/
│   │   ├── auth.routes.ts        # Auth endpoints
│   │   ├── fcm.routes.ts         # FCM endpoints
│   │   └── index.ts              # Route aggregator
│   │
│   └── index.ts                  # Main server file
│
├── package.json                  # Dependencies & scripts
├── tsconfig.json                 # TypeScript configuration
├── nodemon.json                  # Nodemon configuration
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
├── README.md                     # Complete documentation
├── SETUP.md                      # Step-by-step setup guide
├── API_DOCUMENTATION.md          # Detailed API docs
├── database-setup.sql            # SQL setup script
├── generate-secrets.js           # JWT secret generator
└── postman-collection.json       # Postman API collection
```

---

## 🎯 Quick Start Guide

### Step 1: Install Dependencies
```bash
cd backend
npm install
```

### Step 2: Generate JWT Secrets
```bash
node generate-secrets.js
```
Copy the generated secrets to your `.env` file.

### Step 3: Setup Database
```bash
# In MySQL
mysql -u root -p
CREATE DATABASE stream_sync_lite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Step 4: Configure Environment
```bash
# Copy template
copy .env.example .env

# Edit .env with your settings:
# - Update DB_PASSWORD
# - Add generated JWT secrets
# - Configure Firebase path (optional)
```

### Step 5: Start Server
```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm run build
npm start
```

Server runs at: **http://localhost:3000**

---

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login with credentials
- `POST /api/auth/refresh` - Refresh access token
- `GET /api/auth/me` - Get current user (protected)

### FCM
- `POST /api/fcm/register` - Register FCM token (protected)
- `DELETE /api/fcm/unregister` - Unregister FCM token (protected)
- `POST /api/fcm/send` - Send notification (admin only)

### Utility
- `GET /api/health` - Health check

---

## 📊 Database Tables

### Users Table
```sql
id (PK, auto-increment)
name (VARCHAR, required)
email (VARCHAR, unique, required)
password_hash (VARCHAR, bcrypt)
role (ENUM: 'user', 'admin', default: 'user')
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
```

### FCM Tokens Table
```sql
id (PK, auto-increment)
user_id (FK → users.id, CASCADE)
token (TEXT, FCM device token)
platform (ENUM: 'android', 'ios', 'web')
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
UNIQUE(user_id, token)
```

---

## 🧪 Testing

### Option 1: Import Postman Collection
1. Open Postman
2. Import `postman-collection.json`
3. Set `baseUrl` variable
4. Test all endpoints

### Option 2: Use cURL
```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","password":"pass123"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'
```

### Option 3: Use Thunder Client (VS Code Extension)
- Install Thunder Client extension
- Import `postman-collection.json`
- Test directly in VS Code

---

## 🔐 Security Features Implemented

✅ **Password Security**
- BCrypt hashing with 10 salt rounds
- Never returns password_hash in responses
- Minimum 6 character requirement

✅ **JWT Security**
- Separate secrets for access/refresh tokens
- Short-lived access tokens (15 min)
- Longer refresh tokens (7 days)
- Stateless authentication

✅ **Input Validation**
- Joi schemas for all inputs
- Email format validation
- Required field checking
- Type validation

✅ **Authorization**
- JWT middleware for protected routes
- Role-based access control
- Admin-only endpoints

✅ **Database Security**
- Foreign key constraints
- CASCADE delete for cleanup
- Unique constraints on email
- Index optimization

---

## 🎨 Key Features

### 1. Automatic Token Refresh
- Access token expires in 15 minutes
- Client can refresh using refresh token
- Seamless user experience

### 2. Multi-Device FCM Support
- Users can have multiple devices
- Each device has unique FCM token
- Notifications sent to all devices

### 3. Role-Based Access
- Default role: 'user'
- Admin role for privileged operations
- Easy to extend with more roles

### 4. Graceful Error Handling
- Descriptive error messages
- Proper HTTP status codes
- No sensitive data in errors

### 5. Firebase Optional
- App works without Firebase
- FCM features disabled if not configured
- No crashes if Firebase missing

---

## 📝 Environment Variables

Required in `.env`:
```env
PORT=3000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=3306
DB_NAME=stream_sync_lite
DB_USER=root
DB_PASSWORD=your_password

JWT_ACCESS_SECRET=32_char_random_string
JWT_REFRESH_SECRET=32_char_random_string
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

---

## 🐛 Troubleshooting

### "Cannot find module" errors
```bash
npm install
```

### Database connection failed
- Check MySQL is running
- Verify credentials in `.env`
- Create database: `CREATE DATABASE stream_sync_lite;`

### Port already in use
- Change PORT in `.env`
- Or kill process: `netstat -ano | findstr :3000`

### TypeScript errors
```bash
npm run build
```

### Firebase errors
- App works without Firebase
- Check `firebase-service-account.json` path
- Download from Firebase Console

---

## 📚 Documentation Files

- **README.md** - Complete overview and features
- **SETUP.md** - Detailed step-by-step setup
- **API_DOCUMENTATION.md** - All endpoints with examples
- **database-setup.sql** - Database schema and setup
- **postman-collection.json** - API testing collection

---

## 🚦 Next Steps

### For Development:
1. ✅ Install dependencies: `npm install`
2. ✅ Generate JWT secrets: `node generate-secrets.js`
3. ✅ Create MySQL database
4. ✅ Configure `.env` file
5. ✅ Start server: `npm run dev`
6. ✅ Test with Postman/Thunder Client

### For Production:
1. ⚙️ Use strong JWT secrets
2. ⚙️ Setup HTTPS/SSL
3. ⚙️ Configure CORS for specific origins
4. ⚙️ Add rate limiting
5. ⚙️ Setup logging (Winston/Morgan)
6. ⚙️ Use PM2 for process management
7. ⚙️ Setup monitoring (New Relic/DataDog)
8. ⚙️ Regular security audits

### For Flutter Integration:
1. 📱 Use `http` package
2. 📱 Call `/auth/register` and `/auth/login`
3. 📱 Store tokens in Hive/SharedPreferences
4. 📱 Include token in headers: `Authorization: Bearer TOKEN`
5. 📱 Implement auto-refresh on 401 errors
6. 📱 Send FCM token on login
7. 📱 Handle push notifications

---

## 🎉 You're All Set!

Your backend is now ready with:
- ✅ Complete authentication system
- ✅ JWT token management
- ✅ BCrypt password security
- ✅ FCM integration
- ✅ Role-based access
- ✅ Joi validation
- ✅ MySQL database
- ✅ TypeScript safety
- ✅ RESTful API design

**Start the server and begin testing!** 🚀

```bash
npm run dev
```

Visit: http://localhost:3000

---

## 📞 Support

Need help? Check:
1. README.md - Overview
2. SETUP.md - Step-by-step guide
3. API_DOCUMENTATION.md - API details
4. Server logs - Error messages
5. MySQL logs - Database issues

Happy Coding! 💻✨
