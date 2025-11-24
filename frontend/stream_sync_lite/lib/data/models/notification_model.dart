import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'notification_model.g.dart';

enum NotificationType {
  video,
  comment,
  like,
  system,
  other,
}

@HiveType(typeId: 3)
class NotificationModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String preview;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isRead;

  @HiveField(6)
  final String type; // 'video', 'comment', 'like', 'system', 'other'

  @HiveField(7)
  final String? linkedContentId; // video ID, comment ID, etc.

  @HiveField(8)
  final String? thumbnailUrl;

  @HiveField(9)
  final Map<String, dynamic>? data;

  @HiveField(10)
  final bool isSyncedToBackend;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.preview,
    required this.timestamp,
    this.isRead = false,
    this.type = 'other',
    this.linkedContentId,
    this.thumbnailUrl,
    this.data,
    this.isSyncedToBackend = false,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? preview,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? linkedContentId,
    String? thumbnailUrl,
    Map<String, dynamic>? data,
    bool? isSyncedToBackend,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      preview: preview ?? this.preview,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      linkedContentId: linkedContentId ?? this.linkedContentId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      data: data ?? this.data,
      isSyncedToBackend: isSyncedToBackend ?? this.isSyncedToBackend,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      preview: json['preview'] ?? json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
      type: json['type'] ?? 'other',
      linkedContentId: json['linkedContentId'],
      thumbnailUrl: json['thumbnailUrl'],
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isSyncedToBackend: json['isSyncedToBackend'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'preview': preview,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'linkedContentId': linkedContentId,
      'thumbnailUrl': thumbnailUrl,
      'data': data,
      'isSyncedToBackend': isSyncedToBackend,
    };
  }

  NotificationType get notificationType {
    switch (type.toLowerCase()) {
      case 'video':
        return NotificationType.video;
      case 'comment':
        return NotificationType.comment;
      case 'like':
        return NotificationType.like;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.other;
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        preview,
        timestamp,
        isRead,
        type,
        linkedContentId,
        thumbnailUrl,
        data,
        isSyncedToBackend,
      ];
}
