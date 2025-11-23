# Quick Setup Guide for Stream Sync Lite Backend

## Step 1: Install Dependencies

Open a command prompt (CMD) or PowerShell as Administrator and run:

```bash
cd d:\MCA\Flutter\stream_sync_lite\backend
npm install
```

If you get PowerShell execution policy errors, either:
- Run CMD as administrator instead, OR
- Enable scripts in PowerShell: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

## Step 2: Setup MySQL Database

1. Make sure MySQL is running
2. Open MySQL command line or MySQL Workbench
3. Create the database:

```sql
CREATE DATABASE stream_sync_lite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## Step 3: Configure Environment

1. Copy `.env.example` to `.env`:
   ```bash
   copy .env.example .env
   ```

2. Edit `.env` file with your settings:
   - Update `DB_PASSWORD` with your MySQL root password
   - Generate secure JWT secrets (see below)
   - Update Firebase path (optional)

### Generate JWT Secrets

Run this in Node.js REPL or create a temp file:

```javascript
// In Node.js console or save as generate-secrets.js
console.log('JWT_ACCESS_SECRET=' + require('crypto').randomBytes(32).toString('hex'));
console.log('JWT_REFRESH_SECRET=' + require('crypto').randomBytes(32).toString('hex'));
```

Copy these values to your `.env` file.

## Step 4: Setup Firebase (Optional)

1. Go to Firebase Console: https://console.firebase.google.com/
2. Create project or select existing
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Save JSON file as `firebase-service-account.json` in backend folder

**Note**: App works without Firebase, but FCM push notifications will be disabled.

## Step 5: Start the Server

### Development mode (with auto-reload):
```bash
npm run dev
```

### Production mode:
```bash
npm run build
npm start
```

The server will start at: http://localhost:3000

## Step 6: Test the API

### Using curl or Postman/Thunder Client

1. **Health Check**:
   ```
   GET http://localhost:3000/api/health
   ```

2. **Register User**:
   ```
   POST http://localhost:3000/api/auth/register
   Content-Type: application/json
   
   {
     "name": "Test User",
     "email": "test@example.com",
     "password": "password123"
   }
   ```

3. **Login**:
   ```
   POST http://localhost:3000/api/auth/login
   Content-Type: application/json
   
   {
     "email": "test@example.com",
     "password": "password123"
   }
   ```

4. **Access Protected Route**:
   ```
   GET http://localhost:3000/api/auth/me
   Authorization: Bearer YOUR_ACCESS_TOKEN
   ```

## Step 7: Create Admin User (Optional)

After registering a user, update their role in MySQL:

```sql
USE stream_sync_lite;
UPDATE users SET role = 'admin' WHERE email = 'test@example.com';
```

## Common Issues

### 1. MySQL Connection Error
- Check MySQL is running: `net start mysql` or `mysql --version`
- Verify credentials in `.env`
- Ensure database exists

### 2. Port 3000 Already in Use
- Change PORT in `.env` to 3001 or another port
- Or kill process: `netstat -ano | findstr :3000` then `taskkill /PID <pid> /F`

### 3. TypeScript Errors
- Delete `node_modules` and run `npm install` again
- Clear TypeScript cache: delete `dist` folder

### 4. Firebase Not Working
- Check file path in `.env`
- Verify `firebase-service-account.json` exists
- App works without it (FCM disabled)

## What's Next?

Now that your backend is running:
1. Test all endpoints with Postman/Thunder Client
2. Integrate with Flutter frontend
3. Setup HTTPS for production
4. Configure rate limiting
5. Add monitoring/logging

## Backend Features Included

✅ User Registration with email validation
✅ Login with JWT tokens (access + refresh)
✅ Password hashing with BCrypt
✅ Token refresh mechanism
✅ FCM token management for push notifications
✅ Role-based access (user/admin)
✅ Joi validation for all inputs
✅ MySQL database with Sequelize ORM
✅ RESTful API design
✅ TypeScript for type safety
✅ Error handling and logging

Happy Coding! 🚀
