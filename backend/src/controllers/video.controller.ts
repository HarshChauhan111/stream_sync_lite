import { Response } from 'express';
import { Video, VideoProgress } from '../models';
import { Op } from 'sequelize';
import { AuthRequest } from '../middleware/auth.middleware';

/**
 * Get list of videos (latest 10 by default)
 * @route GET /api/videos
 * @access Public (but includes user progress if authenticated)
 */
export const getVideos = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user?.userId;
    const limit = parseInt(req.query.limit as string) || 10;
    const offset = parseInt(req.query.offset as string) || 0;

    // Get latest videos
    const videos = await Video.findAll({
      limit,
      offset,
      order: [['publishedDate', 'DESC']],
    });

    // If user is logged in, get their progress/favorites
    if (userId) {
      const videoIds = videos.map(v => v.id);
      const progressData = await VideoProgress.findAll({
        where: {
          userId,
          videoId: { [Op.in]: videoIds },
        },
      });

      const progressMap = new Map(progressData.map(p => [p.videoId, p]));

      const videosWithProgress = videos.map(video => ({
        id: video.id,
        title: video.title,
        channelName: video.channelName,
        thumbnailUrl: video.thumbnailUrl,
        videoUrl: video.videoUrl,
        duration: video.duration,
        publishedDate: video.publishedDate,
        description: video.description,
        viewCount: video.viewCount,
        likeCount: video.likeCount,
        isFavorite: progressMap.get(video.id)?.isFavorite || false,
        lastPlayedPosition: progressMap.get(video.id)?.lastPlayedPosition || 0,
      }));

      res.json({
        success: true,
        data: videosWithProgress,
        total: await Video.count(),
      });
    } else {
      res.json({
        success: true,
        data: videos,
        total: await Video.count(),
      });
    }
  } catch (error: any) {
    console.error('Error fetching videos:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch videos',
      error: error.message,
    });
  }
};

/**
 * Get a specific video by ID
 * @route GET /api/videos/:id
 * @access Public (but includes user progress if authenticated)
 */
export const getVideoById = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user?.userId;

    const video = await Video.findByPk(id);

    if (!video) {
      res.status(404).json({
        success: false,
        message: 'Video not found',
      });
      return;
    }

    // Get user progress if logged in
    let progress = null;
    if (userId) {
      progress = await VideoProgress.findOne({
        where: { userId, videoId: video.id },
      });
    }

    res.json({
      success: true,
      data: {
        ...video.toJSON(),
        isFavorite: progress?.isFavorite || false,
        lastPlayedPosition: progress?.lastPlayedPosition || 0,
      },
    });
  } catch (error: any) {
    console.error('Error fetching video:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch video',
      error: error.message,
    });
  }
};

/**
 * Update video progress (watch position)
 * @route POST /api/videos/:id/progress
 * @access Private
 */
export const updateVideoProgress = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;
    const { lastPlayedPosition } = req.body;

    if (typeof lastPlayedPosition !== 'number' || lastPlayedPosition < 0) {
      res.status(400).json({
        success: false,
        message: 'Invalid lastPlayedPosition',
      });
      return;
    }

    const video = await Video.findByPk(id);
    if (!video) {
      res.status(404).json({
        success: false,
        message: 'Video not found',
      });
      return;
    }

    // Upsert progress
    const [progress, created] = await VideoProgress.upsert({
      userId,
      videoId: parseInt(id),
      lastPlayedPosition,
    }, {
      conflictFields: ['userId', 'videoId'],
      returning: true,
    });

    res.json({
      success: true,
      message: created ? 'Progress created' : 'Progress updated',
      data: progress,
    });
  } catch (error: any) {
    console.error('Error updating video progress:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update video progress',
      error: error.message,
    });
  }
};

/**
 * Toggle favorite status for a video
 * @route POST /api/videos/:id/favorite
 * @access Private
 */
export const toggleFavorite = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const userId = req.user!.userId;

    const video = await Video.findByPk(id);
    if (!video) {
      res.status(404).json({
        success: false,
        message: 'Video not found',
      });
      return;
    }

    // Get or create progress
    let progress = await VideoProgress.findOne({
      where: { userId, videoId: parseInt(id) },
    });

    if (progress) {
      progress.isFavorite = !progress.isFavorite;
      await progress.save();
    } else {
      progress = await VideoProgress.create({
        userId,
        videoId: parseInt(id),
        isFavorite: true,
        lastPlayedPosition: 0,
      });
    }

    res.json({
      success: true,
      message: progress.isFavorite ? 'Added to favorites' : 'Removed from favorites',
      data: { isFavorite: progress.isFavorite },
    });
  } catch (error: any) {
    console.error('Error toggling favorite:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle favorite',
      error: error.message,
    });
  }
};

/**
 * Get user's favorite videos
 * @route GET /api/videos/favorites
 * @access Private
 */
export const getFavorites = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user!.userId;

    const favorites = await VideoProgress.findAll({
      where: {
        userId,
        isFavorite: true,
      },
      include: [
        {
          model: Video,
          as: 'video',
          required: true,
        },
      ],
      order: [['updatedAt', 'DESC']],
    });

    const videosWithProgress = favorites.map((fav: any) => ({
      ...fav.video?.toJSON(),
      isFavorite: true,
      lastPlayedPosition: fav.lastPlayedPosition,
    }));

    res.json({
      success: true,
      data: videosWithProgress,
    });
  } catch (error: any) {
    console.error('Error fetching favorites:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch favorites',
      error: error.message,
    });
  }
};
