import { Router } from 'express';
import {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  sendTestPush,
  createNotification,
} from '../controllers/notification.controller';
import { authMiddleware, adminMiddleware } from '../middleware/auth.middleware';

const router = Router();

// All notification routes require authentication
router.use(authMiddleware);

router.get('/', getNotifications);
router.post('/test', sendTestPush); // Send test push to current user
router.post('/mark-all-read', markAllAsRead);
router.post('/:id/read', markAsRead);
router.delete('/:id', deleteNotification);

// Admin only - create notification for any user
router.post('/', adminMiddleware, createNotification);

export default router;
