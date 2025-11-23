require('dotenv').config();

export const config = {
  server: {
    port: parseInt(process.env.PORT || '3000', 10),
    env: process.env.NODE_ENV || 'development',
  },
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306', 10),
    name: process.env.DB_NAME || 'stream_sync_lite',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  },
  jwt: {
    accessSecret: process.env.JWT_ACCESS_SECRET || 'your_access_secret_key',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'your_refresh_secret_key',
    accessExpiry: (process.env.JWT_ACCESS_EXPIRY || '15m') as string,
    refreshExpiry: (process.env.JWT_REFRESH_EXPIRY || '7d') as string,
  },
  firebase: {
    serviceAccountPath: process.env.FIREBASE_SERVICE_ACCOUNT_PATH || './firebase-service-account.json',
  },
};
