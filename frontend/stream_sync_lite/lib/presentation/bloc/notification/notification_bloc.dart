import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../data/services/api_service.dart';
import '../../../data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final ApiService _apiService;
  final Logger _logger = Logger();
  
  List<NotificationModel> _allNotifications = [];
  int _unreadCount = 0;

  NotificationBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDeleted>(_onDeleted);
    on<NotificationTestPushSent>(_onTestPushSent);
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      if (event.refresh || state is! NotificationLoaded) {
        emit(const NotificationLoading());
      }

      final response = await _apiService.getNotifications();
      
      final notificationsData = response['notifications'] as List<dynamic>? ?? [];
      _allNotifications = notificationsData
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      _unreadCount = response['unreadCount'] as int? ?? 0;

      emit(NotificationLoaded(
        notifications: List.from(_allNotifications),
        unreadCount: _unreadCount,
      ));
    } catch (e) {
      _logger.e('Load notifications error: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      
      try {
        await _apiService.markNotificationAsRead(event.notificationId);
        
        // Update local notification
        final index = _allNotifications.indexWhere((n) => n.id == event.notificationId);
        if (index != -1) {
          _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
          _unreadCount = (_unreadCount - 1).clamp(0, _allNotifications.length);
        }

        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: _unreadCount,
        ));
      } catch (e) {
        _logger.e('Mark as read error: $e');
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      
      try {
        await _apiService.markAllNotificationsAsRead();
        
        // Update all notifications to read
        _allNotifications = _allNotifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;

        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: 0,
        ));
      } catch (e) {
        _logger.e('Mark all as read error: $e');
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onDeleted(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      
      try {
        await _apiService.deleteNotification(event.notificationId);
        
        // Remove notification from local list
        final deletedNotification = _allNotifications.firstWhere(
          (n) => n.id == event.notificationId,
        );
        
        _allNotifications.removeWhere((n) => n.id == event.notificationId);
        
        if (!deletedNotification.isRead) {
          _unreadCount = (_unreadCount - 1).clamp(0, _allNotifications.length);
        }

        emit(currentState.copyWith(
          notifications: List.from(_allNotifications),
          unreadCount: _unreadCount,
        ));
      } catch (e) {
        _logger.e('Delete notification error: $e');
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onTestPushSent(
    NotificationTestPushSent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _apiService.sendTestPush(
        title: event.title,
        body: event.body,
      );
      
      emit(const NotificationOperationSuccess('Test push sent successfully!'));
      
      // Restore previous state after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (state is NotificationOperationSuccess) {
        add(const NotificationLoadRequested(refresh: true));
      }
    } catch (e) {
      _logger.e('Send test push error: $e');
      emit(NotificationError(e.toString()));
    }
  }
}
