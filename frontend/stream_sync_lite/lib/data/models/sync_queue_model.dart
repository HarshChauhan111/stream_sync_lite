import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'sync_queue_model.g.dart';

enum SyncAction {
  deleteNotification,
  updateVideoProgress,
  toggleFavorite,
  markNotificationRead,
}

@HiveType(typeId: 5)
class SyncQueueModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String action; // 'deleteNotification', 'updateVideoProgress', 'toggleFavorite', etc.

  @HiveField(2)
  final Map<String, dynamic> payload;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retryCount;

  @HiveField(5)
  final DateTime? lastAttemptAt;

  @HiveField(6)
  final String? errorMessage;

  const SyncQueueModel({
    required this.id,
    required this.action,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastAttemptAt,
    this.errorMessage,
  });

  SyncQueueModel copyWith({
    String? id,
    String? action,
    Map<String, dynamic>? payload,
    DateTime? createdAt,
    int? retryCount,
    DateTime? lastAttemptAt,
    String? errorMessage,
  }) {
    return SyncQueueModel(
      id: id ?? this.id,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  SyncAction get syncAction {
    switch (action.toLowerCase()) {
      case 'deletenotification':
        return SyncAction.deleteNotification;
      case 'updatevideoprogress':
        return SyncAction.updateVideoProgress;
      case 'togglefavorite':
        return SyncAction.toggleFavorite;
      case 'marknotificationread':
        return SyncAction.markNotificationRead;
      default:
        return SyncAction.deleteNotification;
    }
  }

  factory SyncQueueModel.fromJson(Map<String, dynamic> json) {
    return SyncQueueModel(
      id: json['id']?.toString() ?? '',
      action: json['action'] ?? '',
      payload: Map<String, dynamic>.from(json['payload'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      retryCount: json['retryCount'] ?? 0,
      lastAttemptAt: json['lastAttemptAt'] != null ? DateTime.parse(json['lastAttemptAt']) : null,
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'errorMessage': errorMessage,
    };
  }

  @override
  List<Object?> get props => [
        id,
        action,
        payload,
        createdAt,
        retryCount,
        lastAttemptAt,
        errorMessage,
      ];
}
