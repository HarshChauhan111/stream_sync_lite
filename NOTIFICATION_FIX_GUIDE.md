# Notification Push Issue - Fix Guide

## Problem
Test push notifications are not working and data is not being stored in the database.

## Root Causes Identified

### 1. Database Column Name Mismatch
**Issue**: The Notification model was using camelCase `userId` but the database expects snake_case `user_id`.

**Fix Applied**: Updated `backend/src/models/Notification.ts` to:
```typescript
userId: {
  type: DataTypes.INTEGER.UNSIGNED,
  allowNull: false,
  field: 'user_id',  // ✅ Added explicit field mapping
  references: {
    model: 'users',
    key: 'id',
  },
  onDelete: 'CASCADE',
},
```

Also added `underscored: true` option to automatically handle snake_case for timestamps.

### 2. Missing Database Table
The `notifications` table might not exist in your database.

## Steps to Fix

### Step 1: Verify Database Table Exists

Run the SQL script provided at `backend/check_notifications_table.sql`:

```bash
mysql -u root -p stream_sync_lite < backend/check_notifications_table.sql
```

Or manually in MySQL:
```sql
USE stream_sync_lite;
SHOW TABLES LIKE 'notifications';
DESCRIBE notifications;
```

### Step 2: Create Table if Missing

If the table doesn't exist, run:

```sql
CREATE TABLE IF NOT EXISTS notifications (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  preview VARCHAR(500) NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT 'other',
  linked_content_id VARCHAR(255) NULL,
  thumbnail_url TEXT NULL,
  data JSON NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_is_read (is_read),
  INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Step 3: Rebuild and Restart Backend

**Windows PowerShell** (with execution policy enabled):
```powershell
cd backend
npm run build
npm run dev
```

**Alternative** (if PowerShell execution policy issue):
```powershell
# Set execution policy (Run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then build and run
cd backend
npm run build
npm run dev
```

**OR use CMD instead**:
```cmd
cd backend
npx tsc
node dist/index.js
```

### Step 4: Test the Notification Endpoint

1. **Login to get a valid token**:
```bash
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "your@email.com",
  "password": "yourpassword"
}
```

2. **Send test notification**:
```bash
POST http://localhost:3000/api/notifications/test
Authorization: Bearer YOUR_ACCESS_TOKEN
Content-Type: application/json

{
  "title": "Test Notification",
  "body": "This is a test notification to verify the system is working!"
}
```

### Step 5: Check Logs

The enhanced logging will now show:
```
📬 Test push notification request: { userId: 1, title: '...', body: '...' }
💾 Creating notification in database...
✅ Notification created: { id: 1, userId: 1, title: '...', ... }
📤 Sending FCM push notification...
✅ FCM notification sent: { successCount: 1, failureCount: 0 }
```

If there's an error, you'll see detailed stack traces.

### Step 6: Verify in Database

```sql
SELECT * FROM notifications ORDER BY created_at DESC LIMIT 5;
```

## Common Issues & Solutions

### Issue: "Field 'user_id' doesn't have a default value"
**Solution**: The model fix should resolve this. Make sure you rebuild the backend after applying the changes.

### Issue: "Table 'stream_sync_lite.notifications' doesn't exist"
**Solution**: Run the SQL script in Step 1 to create the table.

### Issue: "Cannot find module 'D:\\...\\backend\\dist\\index.js'"
**Solution**: You need to build the TypeScript code first:
```bash
cd backend
npx tsc
# or
npm run build
```

### Issue: PowerShell execution policy error
**Solution**: Either:
1. Run `Set-ExecutionPolicy RemoteSigned` as Administrator
2. Use CMD instead of PowerShell
3. Use `npx` directly: `npx tsc` and `node dist/index.js`

### Issue: FCM push fails but notification is created
**Solution**: This is expected if:
- Firebase is not configured (check `firebase-service-account.json`)
- User has no FCM tokens registered
- FCM tokens are invalid/expired

The notification will still be saved to the database and visible in the app.

## Testing Checklist

- [ ] Database table `notifications` exists with correct schema
- [ ] Backend is running without errors
- [ ] Can login and get access token
- [ ] POST to `/api/notifications/test` returns success
- [ ] Notification appears in database
- [ ] Notification appears in Flutter app
- [ ] (Optional) FCM push notification received on device

## Files Modified

1. `backend/src/models/Notification.ts` - Added field mapping and underscored option
2. `backend/src/controllers/notification.controller.ts` - Enhanced logging
3. `backend/check_notifications_table.sql` - Database verification script

## Next Steps

After verifying the notification system works:

1. **Test from Flutter app**:
   - Navigate to Notifications tab
   - Pull to refresh
   - Verify notifications appear

2. **Test FCM push** (if Firebase configured):
   - Ensure device/emulator has FCM token registered
   - Send test notification
   - Verify push appears on device

3. **Test notification features**:
   - Mark as read
   - Delete notification
   - Mark all as read

## Support

If issues persist:
1. Check backend console logs for detailed error messages
2. Verify database connection in backend logs
3. Check MySQL error logs: `sudo tail -f /var/log/mysql/error.log`
4. Verify Firebase configuration if using FCM
