-- Reset database script
DROP DATABASE IF EXISTS stream_sync_lite;
CREATE DATABASE stream_sync_lite;
USE stream_sync_lite;

-- Show success message
SELECT 'Database reset successfully!' AS message;
