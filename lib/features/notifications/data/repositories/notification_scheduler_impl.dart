import '../../domain/repositories/notification_scheduler.dart';
import '../datasources/local_notifications_data_source.dart';

class NotificationSchedulerImpl implements NotificationScheduler {
  final LocalNotificationsDataSource _source;
  NotificationSchedulerImpl(this._source);

  /// المنصة تريد رقماً صحيحاً (31 بت). نحوّل المفتاح النصي لرقم ثابت
  /// (FNV-1a). لا نستخدم hashCode لأنه غير مضمون الثبات بين التشغيلات.
  static int idFor(String key) {
    var h = 0x811c9dc5;
    for (final c in key.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h & 0x7FFFFFFF;
  }

  @override
  Future<void> schedule({
    required String key,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) =>
      _source.schedule(
        id: idFor(key),
        title: title,
        body: body,
        when: when,
        payload: payload,
      );

  @override
  Future<void> cancel(String key) => _source.cancel(idFor(key));

  @override
  Future<void> cancelAll() => _source.cancelAll();
}
