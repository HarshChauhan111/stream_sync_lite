import { Router } from 'express';
import {
  registerFCMToken,
  unregisterFCMToken,
  sendNotification,
  sendFCMToUser,
} from '../services/fcm.service';
import { authMiddleware, adminMiddleware, AuthRequest } from '../middleware/auth.middleware';

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

/**
 * @route   POST /fcm/test-push
 * @desc    Send test notification to current user
 * @access  Private
 */
router.post('/test-push', authMiddleware, async (req: AuthRequest, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
    }

    const { title, body } = req.body;

    if (!title || !body) {
      return res.status(400).json({
        success: false,
        message: 'title and body are required',
      });
    }

    // Send to current user
    const result = await sendFCMToUser(req.user.userId, title, body);

    res.status(200).json({
      success: true,
      message: 'Test notification sent',
      data: result,
    });
  } catch (error: any) {
    console.error('Send test push error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to send test notification',
    });
  }
});

export default router;
