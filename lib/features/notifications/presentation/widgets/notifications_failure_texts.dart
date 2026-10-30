import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/notification_failure.dart';

/// نصوص مفهومة للمستخدم لكل نوع فشل.
extension NotificationsFailureTexts on NotificationsFailureKind {
  String get message => switch (this) {
        NotificationsFailureKind.network =>
          'notifications.error_network'.tr(),
        NotificationsFailureKind.unauthenticated =>
          'notifications.error_unauthenticated'.tr(),
        NotificationsFailureKind.permissionDenied =>
          'notifications.error_permission'.tr(),
        NotificationsFailureKind.server =>
          'notifications.error_server'.tr(),
        NotificationsFailureKind.unknown =>
          'notifications.error_unknown'.tr(),
      };

  IconData get icon => switch (this) {
        NotificationsFailureKind.network => Icons.wifi_off_outlined,
        NotificationsFailureKind.unauthenticated => Icons.lock_outline,
        NotificationsFailureKind.permissionDenied => Icons.block_outlined,
        NotificationsFailureKind.server => Icons.cloud_off_outlined,
        NotificationsFailureKind.unknown => Icons.error_outline,
      };
}
