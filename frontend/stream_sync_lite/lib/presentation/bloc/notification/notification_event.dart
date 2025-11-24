import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  final bool refresh;

  const NotificationLoadRequested({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

class NotificationDeleted extends NotificationEvent {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class NotificationTestPushSent extends NotificationEvent {
  final String title;
  final String body;

  const NotificationTestPushSent({
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [title, body];
}
