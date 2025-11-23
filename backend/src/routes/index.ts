import { Router } from 'express';
import authRoutes from './auth.routes';
import fcmRoutes from './fcm.routes';

const router = Router();

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Server is running',
    timestamp: new Date().toISOString(),
  });
});

// Mount routes
router.use('/auth', authRoutes);
router.use('/fcm', fcmRoutes);

export default router;
