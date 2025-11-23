# MariaDB Connection Error Fix Guide

## Error Summary
```
Host 'Harsh' is not allowed to connect to this MariaDB server
Error Code: ER_HOST_NOT_PRIVILEGED (1130)
```

## Root Cause
The MariaDB server at `10.194.68.200` doesn't allow connections from your computer (hostname: 'Harsh'). This is a permission issue in the database.

## Quick Fix Steps

### Step 1: Connect to MariaDB Server

**Option A: Using MySQL Client (Command Line)**
```bash
mysql -h 10.194.68.200 -u root -p
# Or if you're on the same machine:
mysql -u root -p
```

**Option B: Using phpMyAdmin or MySQL Workbench**
- Open your database management tool
- Connect to the server at `10.194.68.200`

### Step 2: Run the Fix SQL Commands

**For Development (Allow from any host):**
```sql
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'root'@'%';
FLUSH PRIVILEGES;
```

**For Specific Host (More Secure):**
```sql
CREATE USER IF NOT EXISTS 'root'@'Harsh' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'root'@'Harsh';
FLUSH PRIVILEGES;
```

### Step 3: Update Your Backend .env File

Create or edit `backend/.env`:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database Configuration
DB_HOST=10.194.68.200
DB_PORT=3306
DB_NAME=stream_sync_lite
DB_USER=root
DB_PASSWORD=your_actual_password

# JWT Secrets (generate secure keys)
JWT_ACCESS_SECRET=your_super_secret_access_key_here
JWT_REFRESH_SECRET=your_super_secret_refresh_key_here
JWT_ACCESS_EXPIRY=15m
JWT_REFRESH_EXPIRY=7d

# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

### Step 4: Create the Database (if not exists)

```sql
CREATE DATABASE IF NOT EXISTS stream_sync_lite 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;
```

### Step 5: Restart Your Backend

```bash
cd backend
npm run dev
```

## Alternative Solutions

### Solution 1: Use Localhost (If DB is on Same Machine)

If MariaDB is running on your local machine, update `.env`:
```env
DB_HOST=localhost
# or
DB_HOST=127.0.0.1
```

### Solution 2: Create Dedicated Application User (Recommended)

```sql
-- Create a dedicated user for your app
CREATE USER 'stream_sync_user'@'%' IDENTIFIED BY 'StrongPassword123!';

-- Grant privileges only to your database
GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'stream_sync_user'@'%';

-- Apply changes
FLUSH PRIVILEGES;

-- Verify
SHOW GRANTS FOR 'stream_sync_user'@'%';
```

Then update `.env`:
```env
DB_USER=stream_sync_user
DB_PASSWORD=StrongPassword123!
```

### Solution 3: Check MariaDB Server Configuration

If you have access to the server, ensure MariaDB is listening on the network:

**Edit MariaDB config** (`/etc/mysql/mariadb.conf.d/50-server.cnf` on Linux or `my.ini` on Windows):
```ini
[mysqld]
bind-address = 0.0.0.0
```

**Restart MariaDB:**
```bash
# Windows
net stop mariadb
net start mariadb

# Linux
sudo systemctl restart mariadb
```

## Verify the Fix

### Check User Permissions
```sql
-- See all users
SELECT user, host FROM mysql.user;

-- Check specific user grants
SHOW GRANTS FOR 'root'@'%';
```

### Test Connection from Command Line
```bash
mysql -h 10.194.68.200 -u root -p stream_sync_lite
```

### Test Backend Connection
```bash
cd backend
npm run dev
```

You should see:
```
✅ Database connected successfully
✅ Database synchronized
🚀 Server running on port 3000
```

## Common Issues & Solutions

### Issue 1: "Access denied for user"
**Solution:** Wrong password. Update `DB_PASSWORD` in `.env`

### Issue 2: "Can't connect to MySQL server"
**Solution:** 
- Check if MariaDB is running
- Verify firewall allows port 3306
- Check `bind-address` in MariaDB config

### Issue 3: "Unknown database 'stream_sync_lite'"
**Solution:** Create the database:
```sql
CREATE DATABASE stream_sync_lite;
```

### Issue 4: Still getting "Host not allowed"
**Solution:** Make sure you ran `FLUSH PRIVILEGES;` after granting permissions

## Security Best Practices

1. **Never use root in production** - Create a dedicated user
2. **Use strong passwords** - At least 16 characters, mixed case, numbers, symbols
3. **Limit host access** - Use specific hostnames instead of `%` in production
4. **Secure your .env file** - Add `.env` to `.gitignore`
5. **Use SSL/TLS** - Enable encrypted connections for production

## Generate Secure Secrets

Run this in PowerShell to generate strong secrets:
```powershell
# Generate JWT secrets
$accessSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
$refreshSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})

Write-Host "JWT_ACCESS_SECRET=$accessSecret"
Write-Host "JWT_REFRESH_SECRET=$refreshSecret"
```

## Need More Help?

Check the logs for detailed errors:
```bash
cd backend
npm run dev
```

The error messages will tell you exactly what's wrong with the connection.

---

**Current Status:**
- Database Host: `10.194.68.200`
- Database Name: `stream_sync_lite`
- Current Issue: Host 'Harsh' not allowed to connect
- Fix Required: Grant database privileges (see Step 2)
