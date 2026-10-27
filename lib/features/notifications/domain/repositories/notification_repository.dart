import '../entities/app_notification.dart';

/// يُرمى من الـ Repository عند أي فشل، والـ Cubit يعرض [message] (أو يترجمه).
class NotificationsException implements Exception {
  final String message;
  const NotificationsException(this.message);
  @override
  String toString() => message;
}

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications({int limit = 20, int offset = 0});
  Stream<List<AppNotification>> watchNotifications({int limit = 50});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);

  /// يسجّل إشعار الدعاء بالقائمة بعد انتهاء الجلسة (RPC، آمن ومرة واحدة).
  Future<void> recordSessionEndedDua(String sessionId);
}
