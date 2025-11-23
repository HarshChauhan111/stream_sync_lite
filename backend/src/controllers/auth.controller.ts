import { Response } from 'express';
import { AuthRequest } from '../middleware/auth.middleware';
import { User } from '../models';
import { generateTokenPair, verifyRefreshToken } from '../utils/jwt';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
} from '../validations/auth.validation';
import { saveFCMToken } from '../services/fcm.service';

/**
 * Register a new user
 * POST /auth/register
 */
export const register = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // Validate request body
    const { error, value } = registerSchema.validate(req.body);
    if (error) {
      res.status(400).json({
        success: false,
        message: error.details[0].message,
      });
      return;
    }

    const { name, email, password } = value;

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      res.status(409).json({
        success: false,
        message: 'Email already registered',
      });
      return;
    }

    // Hash password
    const password_hash = await User.hashPassword(password);

    // Create new user with role 'user' by default
    const user = await User.create({
      name,
      email,
      password_hash,
      role: 'user' as any,
    });

    // Generate tokens
    const tokens = generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: {
        user: user.toSafeJSON(),
        ...tokens,
      },
    });
  } catch (error: any) {
    console.error('Register error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

/**
 * Login user
 * POST /auth/login
 */
export const login = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // Validate request body
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      res.status(400).json({
        success: false,
        message: error.details[0].message,
      });
      return;
    }

    const { email, password, fcmToken, platform } = value;

    // Find user by email
    const user = await User.findOne({ where: { email } });
    if (!user) {
      res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
      return;
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
      return;
    }

    // Generate tokens
    const tokens = generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    // Save FCM token if provided
    if (fcmToken && platform) {
      try {
        await saveFCMToken(user.id, fcmToken, platform);
      } catch (fcmError) {
        console.error('Failed to save FCM token:', fcmError);
        // Don't fail the login if FCM token save fails
      }
    }

    res.status(200).json({
      success: true,
      message: 'Login successful',
      data: {
        user: user.toSafeJSON(),
        ...tokens,
      },
    });
  } catch (error: any) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

/**
 * Refresh access token
 * POST /auth/refresh
 */
export const refresh = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // Validate request body
    const { error, value } = refreshTokenSchema.validate(req.body);
    if (error) {
      res.status(400).json({
        success: false,
        message: error.details[0].message,
      });
      return;
    }

    const { refreshToken } = value;

    // Verify refresh token
    let decoded;
    try {
      decoded = verifyRefreshToken(refreshToken);
    } catch (err) {
      res.status(401).json({
        success: false,
        message: 'Invalid or expired refresh token',
      });
      return;
    }

    // Check if user still exists
    const user = await User.findByPk(decoded.userId);
    if (!user) {
      res.status(401).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    // Generate new token pair
    const tokens = generateTokenPair({
      userId: user.id,
      email: user.email,
      role: user.role,
    });

    res.status(200).json({
      success: true,
      message: 'Tokens refreshed successfully',
      data: {
        ...tokens,
      },
    });
  } catch (error: any) {
    console.error('Refresh error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};

/**
 * Get current user profile
 * GET /auth/me
 */
export const me = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required',
      });
      return;
    }

    const user = await User.findByPk(req.user.userId);
    if (!user) {
      res.status(404).json({
        success: false,
        message: 'User not found',
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: {
        user: user.toSafeJSON(),
      },
    });
  } catch (error: any) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error.message,
    });
  }
};
