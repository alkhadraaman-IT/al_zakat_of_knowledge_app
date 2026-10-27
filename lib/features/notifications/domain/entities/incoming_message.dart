import 'notification_target.dart';
import 'notification_type.dart';

/// رسالة FCM بعد تحليلها (data-only).
class IncomingMessage {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String? publisherId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? sessionTitle;

  const IncomingMessage({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    this.publisherId,
    this.startsAt,
    this.endsAt,
    this.sessionTitle,
  });

  String? get sessionId => data['session_id'] as String?;

  NotificationTarget? get target {
    final s = data['session_id'] as String?;
    if (s != null) return NotificationTarget(NotificationTargetKind.session, s);
    final m = data['material_id'] as String?;
    if (m != null) return NotificationTarget(NotificationTargetKind.material, m);
    final a = data['article_id'] as String?;
    if (a != null) return NotificationTarget(NotificationTargetKind.article, a);
    return null;
  }
}
