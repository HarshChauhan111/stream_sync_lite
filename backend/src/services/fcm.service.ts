import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { FCMToken } from '../models';
import { fcmTokenSchema } from '../validations/auth.validation';
import { getFirebaseMessaging, isFirebaseInitialized } from '../config/firebase';

/**
 * Save or update FCM token for a user
 */
export const saveFCMToken = async (
  userId: number,
  token: string,
  platform: string
): Promise<void> => {
  try {
    // Check if token already exists for this user
    const existingToken = await FCMToken.findOne({
      where: { user_id: userId, token },
    });

    if (existingToken) {
      // Update platform if changed
      if (existingToken.platform !== platform) {
        existingToken.platform = platform as any;
        await existingToken.save();
      }
    } else {
      // Create new FCM token entry
      await FCMToken.create({
        user_id: userId,
        token,
        platform: platform as any,
      });
    }
  } catch (error) {
    console.error('Error saving FCM token:', error);
    throw error;
  }
};

/**
 * Register FCM token
 * POST /fcm/register
 */
export const registerFCMToken = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
      return;
    }

    // Validate request body
    const { error, value } = fcmTokenSchema.validate(req.body);
    if (error) {
      res.status(400).json({
        success: false,
        message: error.details[0].message,
      });
      return;
    }

    const { token, platform } = value;

    await saveFCMToken(req.user.userId, token, platform);

    res.status(200).json({
      success: true,
      message: 'FCM token registered successfully',
    });
  } catch (error: any) {
    console.error('Register FCM token error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

/**
 * Delete FCM token (logout)
 * DELETE /fcm/unregister
 */
export const unregisterFCMToken = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
      return;
    }

    const { token } = req.body;

    if (!token) {
      res.status(400).json({
        success: false,
        message: 'FCM token is required',
      });
      return;
    }

    // Delete the token
    await FCMToken.destroy({
      where: {
        user_id: req.user.userId,
        token,
      },
    });

    res.status(200).json({
      success: true,
      message: 'FCM token unregistered successfully',
    });
  } catch (error: any) {
    console.error('Unregister FCM token error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

/**
 * Send notification to a user (Admin only)
 * POST /fcm/send
 */
export const sendNotification = async (
  req: AuthRequest,
  res: Response
): Promise<void> => {
  try {
    if (!isFirebaseInitialized()) {
      res.status(503).json({
        success: false,
        message: 'Firebase is not initialized. FCM features are disabled.',
      });
      return;
    }

    const { userId, title, body, data } = req.body;

    if (!userId || !title || !body) {
      res.status(400).json({
        success: false,
        message: 'userId, title, and body are required',
      });
      return;
    }

    // Get all FCM tokens for the user
    const fcmTokens = await FCMToken.findAll({
      where: { user_id: userId },
    });

    if (fcmTokens.length === 0) {
      res.status(404).json({
        success: false,
        message: 'No FCM tokens found for this user',
      });
      return;
    }

    const messaging = getFirebaseMessaging();
    const tokens = fcmTokens.map((t) => t.token);

    // Send notification to all user's devices
    const message = {
      notification: {
        title,
        body,
      },
      data: data || {},
      tokens,
    };

    const response = await messaging.sendEachForMulticast(message);

    // Remove invalid tokens
    if (response.failureCount > 0) {
      const tokensToRemove: string[] = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          tokensToRemove.push(tokens[idx]);
        }
      });

      if (tokensToRemove.length > 0) {
        await FCMToken.destroy({
          where: {
            token: tokensToRemove,
          },
        });
      }
    }

    res.status(200).json({
      success: true,
      message: 'Notification sent successfully',
      data: {
        successCount: response.successCount,
        failureCount: response.failureCount,
      },
    });
  } catch (error: any) {
    console.error('Send notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};
