import '../repositories/notification_repository.dart';
import '../repositories/notification_scheduler.dart';
import 'schedule_session_dua_usecase.dart';
import 'schedule_session_reminder_usecase.dart';

/// يلغي تذكير الجلسة ودعاءها (عند إلغاء الحجز أو إلغاء الجلسة).
class CancelSessionNotificationsUseCase {
  final NotificationScheduler _scheduler;
  final NotificationsRepository _repo;
  const CancelSessionNotificationsUseCase(this._scheduler, this._repo);

  Future<void> call(String sessionId) async {
    for (final key in [
      ScheduleSessionDuaUseCase.keyFor(sessionId),
      ScheduleSessionReminderUseCase.keyFor(sessionId),
    ]) {
      await _scheduler.cancel(key);
      await _repo.removeLocal(key);
    }
  }
}
