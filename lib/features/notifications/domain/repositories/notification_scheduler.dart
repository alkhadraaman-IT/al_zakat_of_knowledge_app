/// جدولة تنبيهات النظام (محلية). التنفيذ الفعلي بطبقة data.
abstract class NotificationScheduler {
  /// يجدول (أو يعيد جدولة) تنبيهاً بمفتاح ثابت. نفس المفتاح = يستبدل السابق.
  Future<void> schedule({
    required String key,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  });

  Future<void> cancel(String key);
  Future<void> cancelAll();
}
