import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart';

enum NotificationsStatus { initial, loading, success, failure }

class NotificationsState extends Equatable {
  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final NotificationsFailureKind? failure;
  final NotificationsFailureKind? partialFailure;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.failure,
    this.partialFailure,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationsFailureKind? failure,
    NotificationsFailureKind? partialFailure,
    bool clearFailure = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      failure: clearFailure ? null : (failure ?? this.failure),
      partialFailure: clearFailure ? null : (partialFailure ?? this.partialFailure),
    );
  }

  @override
  List<Object?> get props => [status, notifications, failure, partialFailure];
}