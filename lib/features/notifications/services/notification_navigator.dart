import 'package:go_router/go_router.dart';

import '../domain/entities/notification_target.dart';

/// فتح وجهة الإشعار من أي مكان (تنبيه النظام، الشريط داخل التطبيق) بدون BuildContext.
/// الـ router يُنشأ داخل التطبيق، فنربطه مرة واحدة بـ [attach].
/// إن ضُغط التنبيه والتطبيق مغلق (الـ router لم يُنشأ بعد) تُحفظ الوجهة وتُفتح عند attach.
class NotificationNavigator {
  NotificationNavigator._();

  static GoRouter? _router;
  static NotificationTarget? _pending;

  static void attach(GoRouter router) {
    _router = router;
    final p = _pending;
    if (p != null) {
      _pending = null;
      open(p);
    }
  }

  static void open(NotificationTarget? target) {
    if (target == null) return;
    final r = _router;
    if (r == null) {
      _pending = target;
      return;
    }
    final path = pathFor(target);
    if (path == null) return; // المسار غير مدعوم بعد — نتجاهل بأمان
    r.push(path); // push: زر الرجوع يعود للشاشة السابقة
  }

  /// يرجع null إن لم تكن شاشة التفاصيل مدعومة بعد.
  static String? pathFor(NotificationTarget t) => switch (t.kind) {
        NotificationTargetKind.session => '/session-details/${t.id}',
        NotificationTargetKind.material => null, // TODO: شاشة تفاصيل الأداة
        NotificationTargetKind.article => null, // TODO: شاشة تفاصيل المقالة
      };
}