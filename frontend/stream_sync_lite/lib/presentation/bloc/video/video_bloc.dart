import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/video_model.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  List<VideoModel> _allVideos = [];
  int _currentOffset = 0;
  static const int _limit = 10;

  VideoBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const VideoInitial()) {
    on<VideoLoadRequested>(_onLoadRequested);
    on<VideoLoadMore>(_onLoadMore);
    on<VideoDetailsRequested>(_onDetailsRequested);
    on<VideoProgressUpdated>(_onProgressUpdated);
    on<VideoFavoriteToggled>(_onFavoriteToggled);
    on<VideoFavoritesLoadRequested>(_onFavoritesLoadRequested);
  }

  Future<void> _onLoadRequested(
    VideoLoadRequested event,
    Emitter<VideoState> emit,
  ) async {
    try {
      if (event.refresh) {
        emit(const VideoLoading());
        _currentOffset = 0;
        _allVideos.clear();
      } else if (state is! VideoLoading) {
        emit(const VideoLoading());
      }

      final videosData = await _apiService.getVideos(
        limit: _limit,
        offset: _currentOffset,
      );

      final videos = videosData.map((json) => VideoModel.fromJson(json)).toList();
      _allVideos.addAll(videos);
      _currentOffset += videos.length;

      emit(VideoLoaded(
        videos: List.from(_allVideos),
        hasMore: videos.length == _limit,
      ));
    } catch (e) {
      _logger.e('Load videos error: $e');
      emit(VideoError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
    VideoLoadMore event,
    Emitter<VideoState> emit,
  ) async {
    if (state is VideoLoaded) {
      final currentState = state as VideoLoaded;
      
      if (!currentState.hasMore) return;

      try {
        emit(VideoLoadingMore(currentState.videos));

        final videosData = await _apiService.getVideos(
          limit: _limit,
          offset: _currentOffset,
        );

        final videos = videosData.map((json) => VideoModel.fromJson(json)).toList();
        _allVideos.addAll(videos);
        _currentOffset += videos.length;

        emit(VideoLoaded(
          videos: List.from(_allVideos),
          hasMore: videos.length == _limit,
        ));
      } catch (e) {
        _logger.e('Load more error: $e');
        emit(currentState); // Restore previous state
      }
    }
  }

  Future<void> _onDetailsRequested(
    VideoDetailsRequested event,
    Emitter<VideoState> emit,
  ) async {
    try {
      emit(const VideoLoading());

      final videoData = await _apiService.getVideoById(event.videoId);
      
      if (videoData != null) {
        final video = VideoModel.fromJson(videoData);
        emit(VideoDetailsLoaded(video));
      } else {
        emit(const VideoError('Video not found'));
      }
    } catch (e) {
      _logger.e('Load video details error: $e');
      emit(VideoError(e.toString()));
    }
  }

  Future<void> _onProgressUpdated(
    VideoProgressUpdated event,
    Emitter<VideoState> emit,
  ) async {
    try {
      await _apiService.updateVideoProgress(
        event.videoId,
        event.position,
      );
      
      // Update local video model
      _updateVideoInList(event.videoId, (video) {
        return video.copyWith(lastPlayedPosition: event.position);
      });
    } catch (e) {
      _logger.e('Update progress error: $e');
    }
  }

  Future<void> _onFavoriteToggled(
    VideoFavoriteToggled event,
    Emitter<VideoState> emit,
  ) async {
    try {
      final success = await _apiService.toggleFavorite(event.videoId);
      
      if (success && state is VideoLoaded) {
        // Toggle favorite in local list
        _updateVideoInList(event.videoId, (video) {
          return video.copyWith(isFavorite: !video.isFavorite);
        });

        final currentState = state as VideoLoaded;
        emit(currentState.copyWith(videos: List.from(_allVideos)));
      }
    } catch (e) {
      _logger.e('Toggle favorite error: $e');
    }
  }

  Future<void> _onFavoritesLoadRequested(
    VideoFavoritesLoadRequested event,
    Emitter<VideoState> emit,
  ) async {
    try {
      emit(const VideoLoading());

      final favoritesData = await _apiService.getFavorites();
      final favorites = favoritesData.map((json) => VideoModel.fromJson(json)).toList();

      emit(VideoFavoritesLoaded(favorites));
    } catch (e) {
      _logger.e('Load favorites error: $e');
      emit(VideoError(e.toString()));
    }
  }

  void _updateVideoInList(String videoId, VideoModel Function(VideoModel) update) {
    final index = _allVideos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      _allVideos[index] = update(_allVideos[index]);
    }
  }
}
