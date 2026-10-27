import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

/// تُستدعى من FCM (محتوى جديد) ومن خدمة الدعاء المحلية.
/// الـ userId داخل الكيان يُستبدل بمعرّف المستخدم الحالي داخل الـ Repository.
class SaveLocalNotificationUseCase {
  final NotificationsRepository _repo;
  const SaveLocalNotificationUseCase(this._repo);

  Future<void> call(AppNotification notification) => _repo.saveLocal(notification);
}
