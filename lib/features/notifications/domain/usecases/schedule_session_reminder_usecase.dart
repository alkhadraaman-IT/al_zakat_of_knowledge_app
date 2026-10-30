import 'package:easy_localization/easy_localization.dart';

import '../entities/app_notification.dart';
import '../entities/notification_target.dart';
import '../entities/notification_type.dart';
import '../entities/session_schedule.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_scheduler.dart';

/// للحاضر (من حجز مقعداً): تذكير قبل بداية الجلسة.
class ScheduleSessionReminderUseCase {
  final NotificationScheduler _scheduler;
  final NotificationsRepository _repo;
  const ScheduleSessionReminderUseCase(this._scheduler, this._repo);

  static String keyFor(String sessionId) => 'reminder_$sessionId';

  Future<void> call(
    SessionSchedule s, {
    Duration lead = const Duration(hours: 1),
  }) async {
    final when = s.startsAt.subtract(lead);
    // الجلسة قريبة جداً أو بدأت: لا معنى للتذكير
    if (!when.isAfter(DateTime.now())) return;

    final key = keyFor(s.sessionId);
    final title = 'notifications.reminder_title'.tr();
    final body = 'notifications.reminder_body'.tr(
      namedArgs: {'title': s.title},
    );

    await _scheduler.schedule(
      key: key,
      title: title,
      body: body,
      when: when,
      payload: NotificationTarget(NotificationTargetKind.session, s.sessionId).toPayload(),
    );

    await _repo.removeLocal(key);
    await _repo.saveLocal(AppNotification(
      id: key,
      userId: '',
      type: NotificationType.sessionReminder,
      title: title,
      body: body,
      data: {'session_id': s.sessionId},
      createdAt: when,
    ));
  }
}
