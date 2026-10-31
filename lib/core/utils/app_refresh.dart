import 'package:flutter/foundation.dart';

/// إشعارات بسيطة لإعادة تحميل القوائم بعد تغيير المحتوى.
/// الاستخدام: استدعِ `AppRefresh.refreshX()` بعد نجاح العملية،
/// وتستمع الشاشة المعنية وتعيد التحميل.
class AppRefresh {
  AppRefresh._();

  static final ValueNotifier<int> sessions = ValueNotifier<int>(0);
  static final ValueNotifier<int> studyTools = ValueNotifier<int>(0);

  /// جديد — لإعادة جلب بروفايل المستخدم (محاضراتي/مقالاتي/أدواتي/حجوزاتي)
  /// بعد الحذف أو التعديل من شاشة أخرى.
  static final ValueNotifier<int> profile = ValueNotifier<int>(0);

  static void refreshSessions() => sessions.value++;
  static void refreshStudyTools() => studyTools.value++;
  static void refreshProfile() => profile.value++;
}