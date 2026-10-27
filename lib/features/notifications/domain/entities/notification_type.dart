/// قيمة `value` = النص المخزّن بعمود `notifications.type` بقاعدة البيانات.
enum NotificationType {
  sessionCancelled('session_cancelled'),
  sessionUpdated('session_updated'),
  materialTaken('material_taken'),
  newSession('new_session'),
  newMaterial('new_material'),
  newArticle('new_article'),
  sessionEndedDua('session_ended_dua'),
  sessionReminder('session_reminder'),
  system('system');

  const NotificationType(this.value);
  final String value;

  /// أي نوع غير معروف (مثلاً أضافه الخادم بعد صدور التطبيق) يصير system
  /// بدل ما يكسر التطبيق.
  static NotificationType fromString(String? v) => values.firstWhere(
        (t) => t.value == v,
        orElse: () => NotificationType.system,
      );
}
