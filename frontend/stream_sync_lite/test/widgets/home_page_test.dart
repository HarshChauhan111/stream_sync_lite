import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stream_sync_lite/data/models/video_model.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_bloc.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_event.dart';
import 'package:stream_sync_lite/presentation/bloc/video/video_state.dart';
import 'package:stream_sync_lite/presentation/pages/home_page.dart';

class MockVideoBloc extends Mock implements VideoBloc {}

void main() {
  late MockVideoBloc mockVideoBloc;

  setUp(() {
    mockVideoBloc = MockVideoBloc();
    // Register fallback values for Mocktail
    registerFallbackValue(const VideoLoadRequested());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<VideoBloc>.value(
        value: mockVideoBloc,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('renders HomePage widget', (WidgetTester tester) async {
      // Arrange
      when(() => mockVideoBloc.state).thenReturn(const VideoInitial());
      when(() => mockVideoBloc.stream).thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('dispatches VideoLoadRequested on init',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockVideoBloc.state).thenReturn(const VideoLoading());
      when(() => mockVideoBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockVideoBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      verify(() => mockVideoBloc.add(any<VideoLoadRequested>())).called(1);
    });

    testWidgets('shows videos when state is VideoLoaded',
        (WidgetTester tester) async {
      // Arrange
      final testVideos = [
        VideoModel(
          id: '1',
          title: 'Test Video 1',
          channelName: 'Test Channel',
          thumbnailUrl: 'https://example.com/thumb1.jpg',
          videoUrl: 'https://example.com/video1.mp4',
          duration: '10:30',
          publishedDate: DateTime.now(),
          isFavorite: false,
        ),
        VideoModel(
          id: '2',
          title: 'Test Video 2',
          channelName: 'Test Channel 2',
          thumbnailUrl: 'https://example.com/thumb2.jpg',
          videoUrl: 'https://example.com/video2.mp4',
          duration: '15:45',
          publishedDate: DateTime.now(),
          isFavorite: true,
        ),
      ];

      when(() => mockVideoBloc.state)
          .thenReturn(VideoLoaded(videos: testVideos, hasMore: true));
      when(() => mockVideoBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockVideoBloc.add(any())).thenReturn(null);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert - verify videos are rendered
      expect(find.text('Test Video 1'), findsOneWidget);
      expect(find.text('Test Video 2'), findsOneWidget);
      expect(find.text('Test Channel'), findsOneWidget);
      expect(find.text('Test Channel 2'), findsOneWidget);
    });
  });
}
