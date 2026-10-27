import '../../domain/entities/app_notification.dart';

enum NotificationsStatus { loading, success, failure }

class NotificationsState {
  final NotificationsStatus status;
  final List<AppNotification> notifications;

  /// رمز الخطأ القادم من الخادم (مثل network_error). يُترجم في الواجهة.
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.loading,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// ملاحظة: errorMessage يُمسح في كل copyWith ما لم يُمرَّر.
  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) =>
      NotificationsState(
        status: status ?? this.status,
        notifications: notifications ?? this.notifications,
        errorMessage: errorMessage,
      );
}
