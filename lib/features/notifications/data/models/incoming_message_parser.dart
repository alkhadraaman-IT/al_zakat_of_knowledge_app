import '../../domain/entities/incoming_message.dart';
import '../../domain/entities/notification_type.dart';

/// يحوّل data الخاصة برسالة FCM (كلها نصوص) إلى [IncomingMessage].
/// يرجع null إن لم تحتوِ title/body (لا شيء نعرضه).
abstract final class IncomingMessageParser {
  static IncomingMessage? tryParse(Map<String, dynamic> raw) {
    final data = <String, dynamic>{
      for (final e in raw.entries) e.key: e.value.toString(),
    };
    final title = data['title'] as String?;
    final body = data['body'] as String?;
    if (title == null || title.isEmpty || body == null) return null;

    final type = NotificationType.fromString(data['type'] as String?);
    final ref = data['session_id'] ?? data['material_id'] ?? data['article_id'];
    // id ثابت يمنع التكرار؛ الخادم يُفضَّل أن يرسله (مثل new_session_<id>)
    final id = (data['id'] as String?) ??
        '${type.value}_${ref ?? DateTime.now().microsecondsSinceEpoch}';

    DateTime? time(String key) => DateTime.tryParse((data[key] as String?) ?? '')?.toLocal();

    return IncomingMessage(
      id: id,
      type: type,
      title: title,
      body: body,
      data: data,
      createdAt: time('created_at') ?? DateTime.now(),
      publisherId: data['publisher_id'] as String?,
      startsAt: time('starts_at'),
      endsAt: time('ends_at'),
      sessionTitle: data['session_title'] as String?,
    );
  }
}
