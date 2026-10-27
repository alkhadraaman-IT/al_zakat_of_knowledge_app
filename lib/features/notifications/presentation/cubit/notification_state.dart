import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart';

enum NotificationsStatus { loading, success, failure }

class NotificationsState {
  final NotificationsStatus status;
  final List<AppNotification> notifications;

  /// فشل كامل أو فشل عملية (status == failure).
  final NotificationsFailureKind? failure;

  /// نجح التحميل المحلي لكن فشل الخادم (status == success): نعرض شريط "فشل التحديث".
  final NotificationsFailureKind? partialFailure;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.notifications = const [],
    this.failure,
    this.partialFailure,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// ملاحظة: failure وpartialFailure يُمسحان في كل copyWith ما لم يُمرَّرا.
  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    NotificationsFailureKind? failure,
    NotificationsFailureKind? partialFailure,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        failure: failure,
        partialFailure: partialFailure,
      );
}
