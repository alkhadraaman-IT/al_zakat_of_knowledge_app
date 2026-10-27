enum NotificationTargetKind { session, material, article }

/// وجهة الضغط على الإشعار. تُحمَّل كنص قصير (payload) مثل: session:abc123
/// والـ main يحوّلها لمسار حسب الـ router (الـ domain لا يعرف المسارات).
class NotificationTarget {
  final NotificationTargetKind kind;
  final String id;
  const NotificationTarget(this.kind, this.id);

  String toPayload() => '${kind.name}:$id';

  static NotificationTarget? parse(String? payload) {
    if (payload == null) return null;
    final i = payload.indexOf(':');
    if (i <= 0 || i == payload.length - 1) return null;
    final kind = NotificationTargetKind.values
        .where((k) => k.name == payload.substring(0, i))
        .firstOrNull;
    return kind == null ? null : NotificationTarget(kind, payload.substring(i + 1));
  }
}
