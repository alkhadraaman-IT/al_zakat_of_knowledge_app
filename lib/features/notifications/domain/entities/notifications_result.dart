import 'app_notification.dart';
import 'notification_failure.dart';

/// نتيجة تحميل القائمة. [remoteFailure] != null يعني أن الخادم فشل،
/// وما نعرضه هو المحفوظ محلياً فقط (يجب إخبار المستخدم بذلك).
class NotificationsResult {
  final List<AppNotification> items;
  final NotificationsFailureKind? remoteFailure;

  const NotificationsResult(this.items, {this.remoteFailure});
}
