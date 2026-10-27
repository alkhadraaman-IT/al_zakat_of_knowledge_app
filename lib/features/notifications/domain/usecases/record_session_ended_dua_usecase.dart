//!============================================
import '../repositories/notification_repository.dart';

/// تُستدعى من خدمة الإشعارات المحلية (الخطوة الجاية) عند انتهاء الجلسة
/// أو عند فتح التطبيق لجلسات منتهية لم تُسجَّل بعد.
class RecordSessionEndedDuaUseCase {
  final NotificationsRepository _repo;
  const RecordSessionEndedDuaUseCase(this._repo);

  Future<void> call(String sessionId) => _repo.recordSessionEndedDua(sessionId);
}
