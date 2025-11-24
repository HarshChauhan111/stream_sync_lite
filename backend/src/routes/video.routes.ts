import { Router } from 'express';
import {
  getVideos,
  getVideoById,
  updateVideoProgress,
  toggleFavorite,
  getFavorites,
} from '../controllers/video.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// Public routes
router.get('/', getVideos); // Can be accessed without auth, but returns more data if authenticated

// Protected routes
router.get('/favorites', authMiddleware, getFavorites);
router.get('/:id', getVideoById); // Can be accessed without auth
router.post('/:id/progress', authMiddleware, updateVideoProgress);
router.post('/:id/favorite', authMiddleware, toggleFavorite);

export default router;
