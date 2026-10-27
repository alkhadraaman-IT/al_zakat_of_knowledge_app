import '../entities/app_notification.dart';
import '../entities/notifications_result.dart';


abstract class NotificationsRepository {
  /// يدمج إشعارات الخادم (الحجوزات) مع المحلية، مرتبة بالأحدث.
  /// يرمي [NotificationsException] إن فشل كل شيء، ويرجع نتيجة فيها
  /// remoteFailure إن فشل الخادم وتوفّر محلي.
  Future<NotificationsResult> getNotifications({int limit = 50});

  /// يحدّد المصدر (محلي أو Supabase) حسب الـ id.
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> delete(String id);

  /// يحفظ إشعاراً محلياً. مكرر الـ id يُتجاهل.
  Future<void> saveLocal(AppNotification notification);

  /// يحذف إشعاراً محلياً فقط (لا يلمس Supabase).
  Future<void> removeLocal(String id);

  /// يصدر عند أي تغيّر يستوجب تحديث القائمة (مخزن محلي أو وصول رسالة).
  Stream<void> watchChanges();
}
