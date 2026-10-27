import '../entities/app_notification.dart';
import '../entities/incoming_message.dart';
import '../entities/notification_type.dart';
import '../entities/session_schedule.dart';
import '../repositories/notification_repository.dart';
import 'cancel_session_notifications_usecase.dart';
import 'schedule_session_reminder_usecase.dart';

/// ماذا نفعل عند وصول رسالة FCM (عرض التنبيه يتم خارجها).
///  - محتوى جديد: يُحفظ محلياً ليظهر بالقائمة.
///  - تعديل جلسة: إعادة جدولة تذكير الحاجز.
///  - إلغاء جلسة: إلغاء تذكيرها.
///  - إشعارات الحجز نفسها تأتي للقائمة من Supabase، فلا تُحفظ محلياً (تفادياً للتكرار).
class HandleIncomingNotificationUseCase {
  final NotificationsRepository _repo;
  final ScheduleSessionReminderUseCase _reminder;
  final CancelSessionNotificationsUseCase _cancel;

  const HandleIncomingNotificationUseCase(this._repo, this._reminder, this._cancel);

  Future<void> call(IncomingMessage m) async {
    switch (m.type) {
      case NotificationType.newSession:
      case NotificationType.newMaterial:
      case NotificationType.newArticle:
        await _repo.saveLocal(AppNotification(
          id: m.id,
          userId: '',
          type: m.type,
          title: m.title,
          body: m.body,
          data: m.data,
          createdAt: m.createdAt,
        ));
      case NotificationType.sessionUpdated:
        final updatedId = m.sessionId;
        if (updatedId != null && m.startsAt != null && m.endsAt != null) {
          await _reminder(SessionSchedule(
            sessionId: updatedId,
            title: m.sessionTitle ?? m.title,
            startsAt: m.startsAt!,
            endsAt: m.endsAt!,
          ));
        }
      case NotificationType.sessionCancelled:
        final cancelledId = m.sessionId;
        if (cancelledId != null) await _cancel(cancelledId);
      default:
        break;
    }
  }
}
