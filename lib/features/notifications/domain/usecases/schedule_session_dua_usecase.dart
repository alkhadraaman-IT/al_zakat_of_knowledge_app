import 'package:easy_localization/easy_localization.dart';

import '../entities/app_notification.dart';
import '../entities/notification_target.dart';
import '../entities/notification_type.dart';
import '../entities/session_schedule.dart';
import '../repositories/notification_repository.dart';
import '../repositories/notification_scheduler.dart';

/// للمحاضر: دعاء عند انتهاء جلسته، ويُسجَّل بالقائمة بوقت الانتهاء.
class ScheduleSessionDuaUseCase {
  final NotificationScheduler _scheduler;
  final NotificationsRepository _repo;
  const ScheduleSessionDuaUseCase(this._scheduler, this._repo);

  static String keyFor(String sessionId) => 'dua_$sessionId';

  Future<void> call(SessionSchedule s) async {
    if (!s.endsAt.isAfter(DateTime.now())) return;

    final key = keyFor(s.sessionId);
    final title = 'notifications.dua_title'.tr();
    final body = 'notifications.dua_body'.tr(
      namedArgs: {'title': s.title},
    );

    await _scheduler.schedule(
      key: key,
      title: title,
      body: body,
      when: s.endsAt,
      payload: NotificationTarget(NotificationTargetKind.session, s.sessionId).toPayload(),
    );

    // نُسجّله بالقائمة مسبقاً بتاريخ المستقبل (الـ Repository يخفيه حتى يحين).
    // نحذف القديم أولاً كي يتحدّث الوقت إن تغيّر موعد الجلسة.
    await _repo.removeLocal(key);
    await _repo.saveLocal(AppNotification(
      id: key,
      userId: '',
      type: NotificationType.sessionEndedDua,
      title: title,
      body: body,
      data: {'session_id': s.sessionId},
      createdAt: s.endsAt,
    ));
  }
}
