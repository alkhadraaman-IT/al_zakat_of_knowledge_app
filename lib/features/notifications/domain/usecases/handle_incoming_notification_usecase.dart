import '../entities/app_notification.dart';
import '../entities/incoming_message.dart';
import '../entities/notification_behavior.dart';
import '../entities/session_schedule.dart';
import '../repositories/notification_repository.dart';
import 'cancel_session_notifications_usecase.dart';
import 'schedule_session_reminder_usecase.dart';

/// يعالج رسالة FCM حسب [NotificationBehavior] الخاص بنوعها (لا منطق مبعثر بالنوع).
/// العرض (شريط/تنبيه نظام) يتم خارج هذه الحالة.
class HandleIncomingNotificationUseCase {
  final NotificationsRepository _repo;
  final ScheduleSessionReminderUseCase _reminder;
  final CancelSessionNotificationsUseCase _cancel;

  const HandleIncomingNotificationUseCase(this._repo, this._reminder, this._cancel);

  Future<void> call(IncomingMessage m) async {
    final b = m.type.behavior;

    // التخزين: serverTable يأتي للقائمة من Supabase، فلا نكرّره محلياً
    if (b.storage == NotificationStorage.deviceOnly) {
      await _repo.saveLocal(AppNotification(
        id: m.id,
        userId: '',
        type: m.type,
        title: m.title,
        body: m.body,
        data: m.data,
        createdAt: m.createdAt,
      ));
    }

    switch (b.sideEffect) {
      case NotificationSideEffect.rescheduleReminder:
        final id = m.sessionId;
        if (id != null && m.startsAt != null && m.endsAt != null) {
          await _reminder(SessionSchedule(
            sessionId: id,
            title: m.sessionTitle ?? m.title,
            startsAt: m.startsAt!,
            endsAt: m.endsAt!,
          ));
        }
      case NotificationSideEffect.cancelSessionAlarms:
        final id = m.sessionId;
        if (id != null) await _cancel(id);
      case NotificationSideEffect.none:
        break;
    }
  }
}
