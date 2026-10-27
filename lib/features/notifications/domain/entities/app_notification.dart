import 'notification_type.dart';

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  // للتوجيه عند الضغط على الإشعار
  String? get sessionId => data?['session_id'] as String?;
  String? get materialId => data?['material_id'] as String?;
  String? get articleId => data?['article_id'] as String?;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
