import 'package:equatable/equatable.dart';
import '../../../data/models/video_model.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {
  const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();
}

class VideoLoadingMore extends VideoState {
  final List<VideoModel> currentVideos;

  const VideoLoadingMore(this.currentVideos);

  @override
  List<Object?> get props => [currentVideos];
}

class VideoLoaded extends VideoState {
  final List<VideoModel> videos;
  final bool hasMore;

  const VideoLoaded({
    required this.videos,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [videos, hasMore];

  VideoLoaded copyWith({
    List<VideoModel>? videos,
    bool? hasMore,
  }) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class VideoDetailsLoaded extends VideoState {
  final VideoModel video;

  const VideoDetailsLoaded(this.video);

  @override
  List<Object?> get props => [video];
}

class VideoError extends VideoState {
  final String message;

  const VideoError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoProgressSaving extends VideoState {
  const VideoProgressSaving();
}

class VideoProgressSaved extends VideoState {
  const VideoProgressSaved();
}

class VideoFavoritesLoaded extends VideoState {
  final List<VideoModel> favorites;

  const VideoFavoritesLoaded(this.favorites);

  @override
  List<Object?> get props => [favorites];
}
