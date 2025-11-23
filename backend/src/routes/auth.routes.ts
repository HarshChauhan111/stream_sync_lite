import { Router } from 'express';
import { register, login, refresh, me } from '../controllers/auth.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

/**
 * @route   POST /auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', register);

/**
 * @route   POST /auth/login
 * @desc    Login user and get tokens
 * @access  Public
 */
router.post('/login', login);

/**
 * @route   POST /auth/refresh
 * @desc    Refresh access token using refresh token
 * @access  Public
 */
router.post('/refresh', refresh);

/**
 * @route   GET /auth/me
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/me', authMiddleware, me);

export default router;
