import { Response } from 'express';
import { Notification, FCMToken } from '../models';
import { sendFCMToUser } from '../services/fcm.service';
import { AuthRequest } from '../middleware/auth.middleware';

/**
 * Get all notifications for the logged in user
 * @route GET /api/notifications
 * @access Private
 */
export const getNotifications = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const limit = parseInt(req.query.limit as string) || 50;
    const offset = parseInt(req.query.offset as string) || 0;

    const notifications = await Notification.findAll({
      where: { userId },
      limit,
      offset,
      order: [['createdAt', 'DESC']],
    });

    const unreadCount = await Notification.count({
      where: { userId, isRead: false },
    });

    res.json({
      success: true,
      data: notifications,
      unreadCount,
      total: await Notification.count({ where: { userId } }),
    });
  } catch (error: any) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch notifications',
      error: error.message,
    });
  }
};

/**
 * Mark a specific notification as read
 * @route POST /api/notifications/:id/read
 * @access Private
 */
export const markAsRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const notification = await Notification.findOne({
      where: { id, userId },
    });

    if (!notification) {
      res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
      return;
    }

    notification.isRead = true;
    await notification.save();

    res.json({
      success: true,
      message: 'Notification marked as read',
      data: notification,
    });
  } catch (error: any) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark notification as read',
      error: error.message,
    });
  }
};

/**
 * Mark all notifications as read for the user
 * @route POST /api/notifications/mark-all-read
 * @access Private
 */
export const markAllAsRead = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;

    await Notification.update(
      { isRead: true },
      { where: { userId, isRead: false } }
    );

    res.json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error: any) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark all notifications as read',
      error: error.message,
    });
  }
};

/**
 * Delete a notification
 * @route DELETE /api/notifications/:id
 * @access Private
 */
export const deleteNotification = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const notification = await Notification.findOne({
      where: { id, userId },
    });

    if (!notification) {
      res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
      return;
    }

    await notification.destroy();

    res.json({
      success: true,
      message: 'Notification deleted',
    });
  } catch (error: any) {
    console.error('Error deleting notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete notification',
      error: error.message,
    });
  }
};

/**
 * Send a test push notification to the user
 * @route POST /api/notifications/test
 * @access Private
 */
export const sendTestPush = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;
    const { title, body } = req.body;

    console.log('📬 Test push notification request:', { userId, title, body });

    if (!title || !body) {
      res.status(400).json({
        success: false,
        message: 'Title and body are required',
      });
      return;
    }

    // Create notification in database
    console.log('💾 Creating notification in database...');
    const notification = await Notification.create({
      userId,
      title,
      body,
      preview: body.substring(0, 100),
      type: 'system',
    });

    console.log('✅ Notification created:', {
      id: notification.id,
      userId: notification.userId,
      title: notification.title,
      type: notification.type,
      isRead: notification.isRead,
    });

    // Send push notification to user's devices
    try {
      console.log('📤 Sending FCM push notification...');
      const result = await sendFCMToUser(
        userId,
        title,
        body,
        {
          notificationId: notification.id.toString(),
          type: 'system',
        }
      );

      console.log('✅ FCM notification sent:', result);

      res.json({
        success: true,
        message: 'Test push notification sent successfully',
        data: notification,
        fcmResult: result,
      });
    } catch (fcmError: any) {
      console.error('❌ FCM Error:', fcmError);
      res.status(500).json({
        success: false,
        message: 'Notification created but failed to send push',
        error: fcmError.message,
        data: notification,
      });
    }
  } catch (error: any) {
    console.error('❌ Error sending test push:', error);
    console.error('Stack trace:', error.stack);
    res.status(500).json({
      success: false,
      message: 'Failed to send test push notification',
      error: error.message,
      details: error.stack,
    });
  }
};

/**
 * Create notification for any user (admin only)
 * @route POST /api/notifications
 * @access Admin
 */
export const createNotification = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { userId, title, body, type, linkedContentId, thumbnailUrl, data } = req.body;

    if (!userId || !title || !body) {
      res.status(400).json({
        success: false,
        message: 'userId, title, and body are required',
      });
      return;
    }

    const notification = await Notification.create({
      userId,
      title,
      body,
      preview: body.substring(0, 100),
      type: type || 'other',
      linkedContentId,
      thumbnailUrl,
      data,
    });

    // Send push notification
    try {
      await sendFCMToUser(
        userId,
        title,
        body,
        {
          notificationId: notification.id.toString(),
          type: notification.type,
          linkedContentId: linkedContentId?.toString() || '',
        }
      );
    } catch (fcmError) {
      console.error('Failed to send FCM notification:', fcmError);
    }

    res.status(201).json({
      success: true,
      message: 'Notification created',
      data: notification,
    });
  } catch (error: any) {
    console.error('Error creating notification:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create notification',
      error: error.message,
    });
  }
};
