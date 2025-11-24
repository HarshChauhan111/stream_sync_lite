import 'package:equatable/equatable.dart';
import '../../../data/models/video_model.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class VideoLoadRequested extends VideoEvent {
  final bool refresh;

  const VideoLoadRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class VideoLoadMore extends VideoEvent {
  const VideoLoadMore();
}

class VideoDetailsRequested extends VideoEvent {
  final String videoId;

  const VideoDetailsRequested(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoProgressUpdated extends VideoEvent {
  final String videoId;
  final int position;

  const VideoProgressUpdated({
    required this.videoId,
    required this.position,
  });

  @override
  List<Object?> get props => [videoId, position];
}

class VideoFavoriteToggled extends VideoEvent {
  final String videoId;

  const VideoFavoriteToggled(this.videoId);

  @override
  List<Object?> get props => [videoId];
}

class VideoFavoritesLoadRequested extends VideoEvent {
  const VideoFavoritesLoadRequested();
}
