import 'package:flutter/foundation.dart';

/// إشعارات بسيطة لإعادة تحميل قوائم الرئيسية بعد إضافة محتوى جديد.
/// الاستخدام: استدعِ AppRefresh.refreshSessions() بعد نجاح الإضافة،
/// وتستمع الصفحة الرئيسية وتعيد التحميل.
class AppRefresh {
  AppRefresh._();

  static final ValueNotifier<int> sessions = ValueNotifier<int>(0);
  static final ValueNotifier<int> studyTools = ValueNotifier<int>(0);

  static void refreshSessions() => sessions.value++;
  static void refreshStudyTools() => studyTools.value++;
}