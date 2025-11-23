import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import { config } from './config';
import { connectDatabase } from './config/database';
import { initializeFirebase } from './config/firebase';
import routes from './routes';

const app: Application = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Mount API routes
app.use('/api', routes);

// Root endpoint
app.get('/', (req: Request, res: Response) => {
  res.status(200).json({
    success: true,
    message: 'Stream Sync Lite Backend API',
    version: '1.0.0',
    endpoints: {
      health: '/api/health',
      auth: {
        register: 'POST /api/auth/register',
        login: 'POST /api/auth/login',
        refresh: 'POST /api/auth/refresh',
        me: 'GET /api/auth/me',
      },
      fcm: {
        register: 'POST /api/fcm/register',
        unregister: 'DELETE /api/fcm/unregister',
        send: 'POST /api/fcm/send (Admin only)',
      },
    },
  });
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
  });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: config.server.env === 'development' ? err.message : undefined,
  });
});

// Start server
const startServer = async () => {
  try {
    // Connect to database
    await connectDatabase();

    // Initialize Firebase (optional - won't crash if fails)
    initializeFirebase();

    // Start listening
    app.listen(config.server.port, () => {
      console.log('========================================');
      console.log(`🚀 Server running on port ${config.server.port}`);
      console.log(`📍 Environment: ${config.server.env}`);
      console.log(`🔗 Base URL: http://localhost:${config.server.port}`);
      console.log(`📚 API Docs: http://localhost:${config.server.port}/api`);
      console.log('========================================');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

export default app;
