import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_sync_lite/data/models/video_model.dart';
import 'package:stream_sync_lite/data/services/api_service.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_event.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_state.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late VideoBloc videoBloc;

  setUp(() {
    mockApiService = MockApiService();
    videoBloc = VideoBloc(apiService: mockApiService);
  });

  tearDown(() {
    videoBloc.close();
  });

  group('VideoBloc', () {
    final testVideos = [
      {
        'id': '1',
        'title': 'Test Video 1',
        'channelName': 'Test Channel',
        'thumbnailUrl': 'https://example.com/thumb1.jpg',
        'videoUrl': 'https://example.com/video1.mp4',
        'duration': '10:30',
        'publishedDate': '2024-01-15T00:00:00.000Z',
        'viewCount': 1000,
        'likeCount': 100,
        'isFavorite': false,
        'lastPlayedPosition': 0,
      },
      {
        'id': '2',
        'title': 'Test Video 2',
        'channelName': 'Test Channel',
        'thumbnailUrl': 'https://example.com/thumb2.jpg',
        'videoUrl': 'https://example.com/video2.mp4',
        'duration': '15:45',
        'publishedDate': '2024-01-16T00:00:00.000Z',
        'viewCount': 2000,
        'likeCount': 200,
        'isFavorite': true,
        'lastPlayedPosition': 60,
      },
    ];

    test('initial state is VideoInitial', () {
      expect(videoBloc.state, const VideoInitial());
    });

    blocTest<VideoBloc, VideoState>(
      'emits [VideoLoading, VideoLoaded] when VideoLoadRequested is added',
      build: () {
        when(() => mockApiService.getVideos(limit: 10, offset: 0))
            .thenAnswer((_) async => testVideos);
        return videoBloc;
      },
      act: (bloc) => bloc.add(const VideoLoadRequested()),
      expect: () => [
        const VideoLoading(),
        isA<VideoLoaded>()
            .having((state) => state.videos.length, 'videos length', 2)
            .having((state) => state.hasMore, 'hasMore', false),
      ],
      verify: (_) {
        verify(() => mockApiService.getVideos(limit: 10, offset: 0)).called(1);
      },
    );

    blocTest<VideoBloc, VideoState>(
      'emits [VideoLoading, VideoError] when API call fails',
      build: () {
        when(() => mockApiService.getVideos(limit: 10, offset: 0))
            .thenThrow(Exception('Network error'));
        return videoBloc;
      },
      act: (bloc) => bloc.add(const VideoLoadRequested()),
      expect: () => [
        const VideoLoading(),
        isA<VideoError>()
            .having((s) => s.message, 'error message', contains('Exception')),
      ],
    );

    blocTest<VideoBloc, VideoState>(
      'toggles favorite status correctly',
      build: () {
        when(() => mockApiService.getVideos(limit: 10, offset: 0))
            .thenAnswer((_) async => testVideos);
        when(() => mockApiService.toggleFavorite('1'))
            .thenAnswer((_) async => true);
        return videoBloc;
      },
      act: (bloc) async {
        bloc.add(const VideoLoadRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const VideoFavoriteToggled('1'));
      },
      skip: 2, // Skip loading states
      expect: () => [
        isA<VideoLoaded>().having(
          (s) => s.videos.firstWhere((v) => v.id == '1').isFavorite,
          'first video isFavorite',
          true,
        ),
      ],
      verify: (_) {
        verify(() => mockApiService.toggleFavorite('1')).called(1);
      },
    );

    blocTest<VideoBloc, VideoState>(
      'loads favorites correctly',
      build: () {
        final favoriteVideos = [testVideos[1]]; // Only the favorited video
        when(() => mockApiService.getFavorites())
            .thenAnswer((_) async => favoriteVideos);
        return videoBloc;
      },
      act: (bloc) => bloc.add(const VideoFavoritesLoadRequested()),
      expect: () => [
        const VideoLoading(),
        isA<VideoFavoritesLoaded>()
            .having((s) => s.favorites.length, 'favorites length', 1)
            .having(
              (s) => s.favorites.first.isFavorite,
              'first favorite isFavorite',
              true,
            ),
      ],
      verify: (_) {
        verify(() => mockApiService.getFavorites()).called(1);
      },
    );

    blocTest<VideoBloc, VideoState>(
      'updates video progress',
      build: () {
        when(() => mockApiService.updateVideoProgress('1', 120))
            .thenAnswer((_) async => true);
        return videoBloc;
      },
      act: (bloc) => bloc.add(const VideoProgressUpdated(videoId: '1', position: 120)),
      expect: () => [], // No state change for progress update
      verify: (_) {
        verify(() => mockApiService.updateVideoProgress('1', 120)).called(1);
      },
    );
  });
}
