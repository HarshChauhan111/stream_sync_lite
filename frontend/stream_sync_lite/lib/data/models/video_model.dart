import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'video_model.g.dart';

@HiveType(typeId: 1)
class VideoModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String channelName;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final String videoUrl;

  @HiveField(5)
  final String duration;

  @HiveField(6)
  final DateTime publishedDate;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final int viewCount;

  @HiveField(9)
  final int likeCount;

  @HiveField(10)
  final bool isFavorite;

  @HiveField(11)
  final int lastPlayedPosition;

  @HiveField(12)
  final bool isCached;

  @HiveField(13)
  final String? cachedVideoPath;

  @HiveField(14)
  final List<VideoChapter>? chapters;

  const VideoModel({
    required this.id,
    required this.title,
    required this.channelName,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.publishedDate,
    this.description,
    this.viewCount = 0,
    this.likeCount = 0,
    this.isFavorite = false,
    this.lastPlayedPosition = 0,
    this.isCached = false,
    this.cachedVideoPath,
    this.chapters,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? channelName,
    String? thumbnailUrl,
    String? videoUrl,
    String? duration,
    DateTime? publishedDate,
    String? description,
    int? viewCount,
    int? likeCount,
    bool? isFavorite,
    int? lastPlayedPosition,
    bool? isCached,
    String? cachedVideoPath,
    List<VideoChapter>? chapters,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      channelName: channelName ?? this.channelName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayedPosition: lastPlayedPosition ?? this.lastPlayedPosition,
      isCached: isCached ?? this.isCached,
      cachedVideoPath: cachedVideoPath ?? this.cachedVideoPath,
      chapters: chapters ?? this.chapters,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final publishedDateStr = json['publishedDate'] as String?;
    final publishedDate = publishedDateStr != null
        ? DateTime.parse(publishedDateStr)
        : DateTime.now();

    return VideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      channelName: json['channelName'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '0:00',
      publishedDate: publishedDate,
      description: json['description'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastPlayedPosition: json['lastPlayedPosition'] as int? ?? 0,
      isCached: json['isCached'] as bool? ?? false,
      cachedVideoPath: json['cachedVideoPath'] as String?,
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
              .map((e) => VideoChapter.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'channelName': channelName,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'publishedDate': publishedDate.toIso8601String(),
      'description': description,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isFavorite': isFavorite,
      'lastPlayedPosition': lastPlayedPosition,
      'isCached': isCached,
      'cachedVideoPath': cachedVideoPath,
      'chapters': chapters?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        channelName,
        thumbnailUrl,
        videoUrl,
        duration,
        publishedDate,
        description,
        viewCount,
        likeCount,
        isFavorite,
        lastPlayedPosition,
        isCached,
        cachedVideoPath,
        chapters,
      ];
}

@HiveType(typeId: 2)
class VideoChapter extends Equatable {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final int startTime;

  const VideoChapter({
    required this.title,
    required this.startTime,
  });

  factory VideoChapter.fromJson(Map<String, dynamic> json) {
    return VideoChapter(
      title: json['title'] as String? ?? '',
      startTime: json['startTime'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startTime': startTime,
    };
  }

  @override
  List<Object?> get props => [title, startTime];
}
