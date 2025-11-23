-- Stream Sync Lite Database Setup
-- Run this script in MySQL to create the database

-- Create database
CREATE DATABASE IF NOT EXISTS stream_sync_lite 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE stream_sync_lite;

-- The tables will be automatically created by Sequelize when you start the server
-- But if you want to create them manually, here are the schemas:

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- FCM Tokens table
CREATE TABLE IF NOT EXISTS fcm_tokens (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    token TEXT NOT NULL,
    platform ENUM('android', 'ios', 'web') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE KEY unique_user_token (user_id, token(255)),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create a sample admin user (password: admin123)
-- Password hash for 'admin123' generated with bcrypt
INSERT INTO users (name, email, password_hash, role) 
VALUES (
    'Admin User', 
    'admin@example.com', 
    '$2b$10$vI8aWBnW3fID.ZQ4/zo1G.q1lRps.9cGLcZEiGDMVr5yUP1KUOYTa',
    'admin'
)
ON DUPLICATE KEY UPDATE email=email;

-- Verify tables were created
SHOW TABLES;

-- Show table structures
DESCRIBE users;
DESCRIBE fcm_tokens;

-- Show sample data
SELECT id, name, email, role, created_at FROM users;

SELECT 'Database setup complete!' as Status;
