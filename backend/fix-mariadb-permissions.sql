-- MariaDB Permission Fix Script
-- Run this script as a database administrator

-- Problem: Host 'Harsh' is not allowed to connect to this MariaDB server
-- Error Code: ER_HOST_NOT_PRIVILEGED (1130)

-- ============================================
-- SOLUTION 1: Allow connection from any host (Development/Testing)
-- ============================================
-- This allows the 'root' user to connect from any IP address
-- Use this for development environments

-- Create user if doesn't exist and grant privileges
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'your_password_here';
GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'root'@'%';
FLUSH PRIVILEGES;

-- ============================================
-- SOLUTION 2: Allow connection from specific host (Recommended for Production)
-- ============================================
-- This allows the 'root' user to connect only from host 'Harsh'
-- More secure option

-- CREATE USER IF NOT EXISTS 'root'@'Harsh' IDENTIFIED BY 'your_password_here';
-- GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'root'@'Harsh';
-- FLUSH PRIVILEGES;

-- ============================================
-- SOLUTION 3: Create a dedicated database user (Best Practice)
-- ============================================
-- Create a specific user for your application
-- Replace 'stream_sync_user' and 'secure_password_123' with your values

-- CREATE USER IF NOT EXISTS 'stream_sync_user'@'%' IDENTIFIED BY 'secure_password_123';
-- GRANT ALL PRIVILEGES ON stream_sync_lite.* TO 'stream_sync_user'@'%';
-- FLUSH PRIVILEGES;

-- ============================================
-- Verify the changes
-- ============================================
-- Run these commands to verify permissions:

-- Show all users
SELECT user, host FROM mysql.user;

-- Show specific user privileges
SHOW GRANTS FOR 'root'@'%';

-- ============================================
-- Additional Notes
-- ============================================
-- 1. Make sure to replace 'your_password_here' with your actual password
-- 2. After running this script, update your .env file with:
--    DB_USER=root
--    DB_PASSWORD=your_password_here
--    DB_HOST=10.194.68.200
--    DB_NAME=stream_sync_lite
-- 3. Restart your Node.js application
-- 4. For production, use SOLUTION 3 with a dedicated user

-- ============================================
-- Troubleshooting
-- ============================================
-- If you still face issues:

-- 1. Check MariaDB is listening on all interfaces:
--    Find my.cnf or mariadb.conf and ensure:
--    bind-address = 0.0.0.0

-- 2. Check firewall allows port 3306:
--    Windows: netsh advfirewall firewall add rule name="MariaDB" dir=in action=allow protocol=TCP localport=3306

-- 3. Restart MariaDB service:
--    Windows: net stop mariadb && net start mariadb
--    Linux: sudo systemctl restart mariadb
