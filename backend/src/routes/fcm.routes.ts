import { Router } from 'express';
import {
  registerFCMToken,
  unregisterFCMToken,
  sendNotification,
} from '../services/fcm.service';
import { authMiddleware, adminMiddleware } from '../middleware/auth.middleware';

const router = Router();

/**
 * @route   POST /fcm/register
 * @desc    Register FCM token for push notifications
 * @access  Private
 */
router.post('/register', authMiddleware, registerFCMToken);

/**
 * @route   DELETE /fcm/unregister
 * @desc    Unregister FCM token (logout)
 * @access  Private
 */
router.delete('/unregister', authMiddleware, unregisterFCMToken);

/**
 * @route   POST /fcm/send
 * @desc    Send notification to a user (Admin only)
 * @access  Private (Admin)
 */
router.post('/send', authMiddleware, adminMiddleware, sendNotification);

export default router;
