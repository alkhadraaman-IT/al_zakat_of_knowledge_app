import 'package:flutter/material.dart';

import '../../domain/entities/notification_type.dart';

/// المظهر الخاص بكل نوع (أيقونة + هل هو تنبيه حرج).
/// السلوك (تخزين/أثر جانبي) في domain/entities/notification_behavior.dart.
class NotificationTypeStyle {
  final IconData icon;
  final bool isAlert;
  const NotificationTypeStyle(this.icon, {this.isAlert = false});
}

extension NotificationTypeStyleX on NotificationType {
  NotificationTypeStyle get style => switch (this) {
        NotificationType.sessionCancelled =>
          const NotificationTypeStyle(Icons.event_busy_outlined, isAlert: true),
        NotificationType.sessionUpdated =>
          const NotificationTypeStyle(Icons.edit_calendar_outlined),
        NotificationType.materialTaken =>
          const NotificationTypeStyle(Icons.check_circle_outline),
        NotificationType.newSession =>
          const NotificationTypeStyle(Icons.groups_2_outlined),
        NotificationType.newMaterial =>
          const NotificationTypeStyle(Icons.menu_book_outlined),
        NotificationType.newArticle =>
          const NotificationTypeStyle(Icons.article_outlined),
        NotificationType.sessionEndedDua =>
          const NotificationTypeStyle(Icons.favorite_border),
        NotificationType.sessionReminder =>
          const NotificationTypeStyle(Icons.alarm_outlined),
        NotificationType.system =>
          const NotificationTypeStyle(Icons.notifications_outlined),
      };
}
