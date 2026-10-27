import 'package:flutter/material.dart';

import '../../domain/entities/notification_failure.dart';

/// نصوص مفهومة للمستخدم لكل نوع فشل (لاحقاً انقلها لملفات الترجمة).
extension NotificationsFailureTexts on NotificationsFailureKind {
  String get message => switch (this) {
        NotificationsFailureKind.network =>
          'تعذّر الاتصال بالإنترنت. تحقق من الشبكة ثم أعد المحاولة.',
        NotificationsFailureKind.unauthenticated =>
          'انتهت جلسة الدخول. سجّل الدخول من جديد.',
        NotificationsFailureKind.permissionDenied =>
          'ليست لديك صلاحية لعرض هذه الإشعارات.',
        NotificationsFailureKind.server =>
          'حدث خطأ في الخادم. حاول مرة أخرى بعد قليل.',
        NotificationsFailureKind.unknown => 'حدث خطأ غير متوقع.',
      };

  IconData get icon => switch (this) {
        NotificationsFailureKind.network => Icons.wifi_off_outlined,
        NotificationsFailureKind.unauthenticated => Icons.lock_outline,
        NotificationsFailureKind.permissionDenied => Icons.block_outlined,
        NotificationsFailureKind.server => Icons.cloud_off_outlined,
        NotificationsFailureKind.unknown => Icons.error_outline,
      };
}
