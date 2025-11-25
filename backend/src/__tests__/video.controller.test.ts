import { Request, Response } from 'express';
import { getVideos, getVideoById, toggleFavorite, getFavorites } from '../controllers/video.controller';
import { Video, VideoProgress } from '../models';
import { AuthRequest } from '../middleware/auth.middleware';

// Mock the models
jest.mock('../models', () => ({
  Video: {
    findAll: jest.fn(),
    findByPk: jest.fn(),
    count: jest.fn(),
  },
  VideoProgress: {
    findAll: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
  },
}));

describe('Video Controller', () => {
  let mockRequest: Partial<AuthRequest>;
  let mockResponse: Partial<Response>;
  let responseObject: any;

  beforeEach(() => {
    responseObject = {};
    mockRequest = {
      user: { userId: 1, email: 'test@example.com', role: 'user' },
      query: {},
      params: {},
    };
    mockResponse = {
      json: jest.fn().mockReturnValue(responseObject),
      status: jest.fn().mockReturnThis(),
    };
    jest.clearAllMocks();
  });

  describe('getVideos', () => {
    it('should return videos with progress for authenticated user', async () => {
      const mockVideos = [
        { id: 1, title: 'Video 1', channelName: 'Channel 1', thumbnailUrl: 'thumb1.jpg', videoUrl: 'video1.mp4', duration: '10:00', publishedDate: new Date(), description: 'Desc 1', viewCount: 100, likeCount: 10 },
        { id: 2, title: 'Video 2', channelName: 'Channel 2', thumbnailUrl: 'thumb2.jpg', videoUrl: 'video2.mp4', duration: '15:00', publishedDate: new Date(), description: 'Desc 2', viewCount: 200, likeCount: 20 },
      ];

      const mockProgress = [
        { videoId: 1, isFavorite: true, lastPlayedPosition: 120 },
        { videoId: 2, isFavorite: false, lastPlayedPosition: 0 },
      ];

      (Video.findAll as jest.Mock).mockResolvedValue(mockVideos);
      (VideoProgress.findAll as jest.Mock).mockResolvedValue(mockProgress);
      (Video.count as jest.Mock).mockResolvedValue(2);

      await getVideos(mockRequest as AuthRequest, mockResponse as Response);

      expect(Video.findAll).toHaveBeenCalledWith({
        limit: 10,
        offset: 0,
        order: [['publishedDate', 'DESC']],
      });

      expect(VideoProgress.findAll).toHaveBeenCalled();
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: true,
        data: expect.arrayContaining([
          expect.objectContaining({
            id: 1,
            title: 'Video 1',
            isFavorite: true,
            lastPlayedPosition: 120,
          }),
        ]),
        total: 2,
      });
    });

    it('should return videos without progress for unauthenticated user', async () => {
      const mockVideos = [
        { id: 1, title: 'Video 1', channelName: 'Channel 1', thumbnailUrl: 'thumb1.jpg', videoUrl: 'video1.mp4', duration: '10:00', publishedDate: new Date(), description: 'Desc 1', viewCount: 100, likeCount: 10 },
      ];

      mockRequest.user = undefined;
      (Video.findAll as jest.Mock).mockResolvedValue(mockVideos);
      (Video.count as jest.Mock).mockResolvedValue(1);

      await getVideos(mockRequest as AuthRequest, mockResponse as Response);

      expect(VideoProgress.findAll).not.toHaveBeenCalled();
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: true,
        data: mockVideos,
        total: 1,
      });
    });

    it('should handle errors gracefully', async () => {
      (Video.findAll as jest.Mock).mockRejectedValue(new Error('Database error'));

      await getVideos(mockRequest as AuthRequest, mockResponse as Response);

      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: false,
        message: 'Failed to fetch videos',
        error: 'Database error',
      });
    });
  });

  describe('toggleFavorite', () => {
    it('should toggle favorite status for existing progress', async () => {
      const mockVideo = { id: 1, title: 'Test Video' };
      const mockProgress = {
        userId: 1,
        videoId: 1,
        isFavorite: false,
        lastPlayedPosition: 0,
        save: jest.fn(),
      };

      mockRequest.params = { id: '1' };
      (Video.findByPk as jest.Mock).mockResolvedValue(mockVideo);
      (VideoProgress.findOne as jest.Mock).mockResolvedValue(mockProgress);

      await toggleFavorite(mockRequest as AuthRequest, mockResponse as Response);

      expect(mockProgress.isFavorite).toBe(true);
      expect(mockProgress.save).toHaveBeenCalled();
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: true,
        message: 'Added to favorites',
        data: expect.objectContaining({
          isFavorite: true,
        }),
      });
    });

    it('should create new progress record if none exists', async () => {
      const mockVideo = { id: 1, title: 'Test Video' };
      const mockNewProgress = {
        userId: 1,
        videoId: 1,
        isFavorite: true,
        lastPlayedPosition: 0,
      };

      mockRequest.params = { id: '1' };
      (Video.findByPk as jest.Mock).mockResolvedValue(mockVideo);
      (VideoProgress.findOne as jest.Mock).mockResolvedValue(null);
      (VideoProgress.create as jest.Mock).mockResolvedValue(mockNewProgress);

      await toggleFavorite(mockRequest as AuthRequest, mockResponse as Response);

      expect(VideoProgress.create).toHaveBeenCalledWith({
        userId: 1,
        videoId: 1,
        isFavorite: true,
        lastPlayedPosition: 0,
      });

      expect(mockResponse.json).toHaveBeenCalledWith({
        success: true,
        message: 'Added to favorites',
        data: mockNewProgress,
      });
    });

    it('should return 404 if video not found', async () => {
      mockRequest.params = { id: '999' };
      (Video.findByPk as jest.Mock).mockResolvedValue(null);

      await toggleFavorite(mockRequest as AuthRequest, mockResponse as Response);

      expect(mockResponse.status).toHaveBeenCalledWith(404);
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: false,
        message: 'Video not found',
      });
    });
  });

  describe('getFavorites', () => {
    it('should return only favorited videos', async () => {
      const mockFavorites = [
        { id: 1, title: 'Favorite Video 1', isFavorite: true },
        { id: 2, title: 'Favorite Video 2', isFavorite: true },
      ];

      (VideoProgress.findAll as jest.Mock).mockResolvedValue([
        { videoId: 1 },
        { videoId: 2 },
      ]);
      (Video.findAll as jest.Mock).mockResolvedValue(mockFavorites);

      await getFavorites(mockRequest as AuthRequest, mockResponse as Response);

      expect(VideoProgress.findAll).toHaveBeenCalledWith({
        where: { userId: 1, isFavorite: true },
      });

      expect(mockResponse.json).toHaveBeenCalledWith({
        success: true,
        data: mockFavorites,
      });
    });
  });
});
