-- Check if notifications table exists
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stream_sync_lite' 
  AND TABLE_NAME = 'notifications'
ORDER BY ORDINAL_POSITION;

-- Check table structure
DESCRIBE stream_sync_lite.notifications;

-- If table doesn't exist or has wrong structure, create/recreate it
-- DROP TABLE IF EXISTS stream_sync_lite.notifications;

CREATE TABLE IF NOT EXISTS stream_sync_lite.notifications (
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

-- Check if table was created successfully
SELECT COUNT(*) as table_exists 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'stream_sync_lite' 
  AND TABLE_NAME = 'notifications';

-- Show sample data (if any)
SELECT * FROM stream_sync_lite.notifications LIMIT 5;
