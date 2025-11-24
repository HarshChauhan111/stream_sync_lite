import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'download_model.g.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
}

@HiveType(typeId: 4)
class DownloadModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String videoId;

  @HiveField(2)
  final String videoTitle;

  @HiveField(3)
  final String videoUrl;

  @HiveField(4)
  final String thumbnailUrl;

  @HiveField(5)
  final String localPath;

  @HiveField(6)
  final String status; // 'pending', 'downloading', 'completed', 'failed', 'paused'

  @HiveField(7)
  final double progress; // 0.0 to 1.0

  @HiveField(8)
  final int totalBytes;

  @HiveField(9)
  final int downloadedBytes;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? completedAt;

  @HiveField(12)
  final String? errorMessage;

  const DownloadModel({
    required this.id,
    required this.videoId,
    required this.videoTitle,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.localPath,
    this.status = 'pending',
    this.progress = 0.0,
    this.totalBytes = 0,
    this.downloadedBytes = 0,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
  });

  DownloadModel copyWith({
    String? id,
    String? videoId,
    String? videoTitle,
    String? videoUrl,
    String? thumbnailUrl,
    String? localPath,
    String? status,
    double? progress,
    int? totalBytes,
    int? downloadedBytes,
    DateTime? createdAt,
    DateTime? completedAt,
    String? errorMessage,
  }) {
    return DownloadModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      videoTitle: videoTitle ?? this.videoTitle,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPath: localPath ?? this.localPath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  DownloadStatus get downloadStatus {
    switch (status.toLowerCase()) {
      case 'pending':
        return DownloadStatus.pending;
      case 'downloading':
        return DownloadStatus.downloading;
      case 'completed':
        return DownloadStatus.completed;
      case 'failed':
        return DownloadStatus.failed;
      case 'paused':
        return DownloadStatus.paused;
      default:
        return DownloadStatus.pending;
    }
  }

  bool get isCompleted => status == 'completed';
  bool get isDownloading => status == 'downloading';
  bool get isFailed => status == 'failed';

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id']?.toString() ?? '',
      videoId: json['videoId'] ?? '',
      videoTitle: json['videoTitle'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      localPath: json['localPath'] ?? '',
      status: json['status'] ?? 'pending',
      progress: (json['progress'] ?? 0.0).toDouble(),
      totalBytes: json['totalBytes'] ?? 0,
      downloadedBytes: json['downloadedBytes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'videoTitle': videoTitle,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'localPath': localPath,
      'status': status,
      'progress': progress,
      'totalBytes': totalBytes,
      'downloadedBytes': downloadedBytes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
        id,
        videoId,
        videoTitle,
        videoUrl,
        thumbnailUrl,
        localPath,
        status,
        progress,
        totalBytes,
        downloadedBytes,
        createdAt,
        completedAt,
        errorMessage,
      ];
}
