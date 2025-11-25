import 'package:flutter_test/flutter_test.dart';
import 'package:stream_sync_lite/data/models/video_model.dart';

void main() {
  group('VideoModel', () {
    test('should create VideoModel from JSON correctly', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Video',
        'channelName': 'Test Channel',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'videoUrl': 'https://example.com/video.mp4',
        'duration': '10:30',
        'publishedDate': '2024-01-15T00:00:00.000Z',
        'description': 'Test description',
        'viewCount': 1000,
        'likeCount': 100,
        'isFavorite': true,
        'lastPlayedPosition': 60,
      };

      // Act
      final video = VideoModel.fromJson(json);

      // Assert
      expect(video.id, '1');
      expect(video.title, 'Test Video');
      expect(video.channelName, 'Test Channel');
      expect(video.thumbnailUrl, 'https://example.com/thumb.jpg');
      expect(video.videoUrl, 'https://example.com/video.mp4');
      expect(video.duration, '10:30');
      expect(video.description, 'Test description');
      expect(video.viewCount, 1000);
      expect(video.likeCount, 100);
      expect(video.isFavorite, true);
      expect(video.lastPlayedPosition, 60);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Test Video',
        'channelName': 'Test Channel',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'videoUrl': 'https://example.com/video.mp4',
        'duration': '10:30',
        'publishedDate': '2024-01-15T00:00:00.000Z',
      };

      // Act
      final video = VideoModel.fromJson(json);

      // Assert
      expect(video.description, null);
      expect(video.viewCount, 0);
      expect(video.likeCount, 0);
      expect(video.isFavorite, false);
      expect(video.lastPlayedPosition, 0);
    });

    test('should convert VideoModel to JSON correctly', () {
      // Arrange
      final video = VideoModel(
        id: '1',
        title: 'Test Video',
        channelName: 'Test Channel',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        videoUrl: 'https://example.com/video.mp4',
        duration: '10:30',
        publishedDate: DateTime.parse('2024-01-15T00:00:00.000Z'),
        description: 'Test description',
        viewCount: 1000,
        likeCount: 100,
        isFavorite: true,
        lastPlayedPosition: 60,
      );

      // Act
      final json = video.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['title'], 'Test Video');
      expect(json['channelName'], 'Test Channel');
      expect(json['isFavorite'], true);
      expect(json['lastPlayedPosition'], 60);
    });

    test('should create copy with updated values', () {
      // Arrange
      final original = VideoModel(
        id: '1',
        title: 'Test Video',
        channelName: 'Test Channel',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        videoUrl: 'https://example.com/video.mp4',
        duration: '10:30',
        publishedDate: DateTime.now(),
        isFavorite: false,
        lastPlayedPosition: 0,
      );

      // Act
      final updated = original.copyWith(
        isFavorite: true,
        lastPlayedPosition: 120,
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.isFavorite, true);
      expect(updated.lastPlayedPosition, 120);
    });

    test('should support equality comparison', () {
      // Arrange
      final video1 = VideoModel(
        id: '1',
        title: 'Test Video',
        channelName: 'Test Channel',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        videoUrl: 'https://example.com/video.mp4',
        duration: '10:30',
        publishedDate: DateTime.parse('2024-01-15T00:00:00.000Z'),
      );

      final video2 = VideoModel(
        id: '1',
        title: 'Test Video',
        channelName: 'Test Channel',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        videoUrl: 'https://example.com/video.mp4',
        duration: '10:30',
        publishedDate: DateTime.parse('2024-01-15T00:00:00.000Z'),
      );

      final video3 = VideoModel(
        id: '2',
        title: 'Different Video',
        channelName: 'Test Channel',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        videoUrl: 'https://example.com/video.mp4',
        duration: '10:30',
        publishedDate: DateTime.parse('2024-01-15T00:00:00.000Z'),
      );

      // Assert
      expect(video1, equals(video2));
      expect(video1, isNot(equals(video3)));
    });
  });
}
