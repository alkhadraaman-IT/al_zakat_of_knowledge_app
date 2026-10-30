import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.body,
    super.data,
    super.isRead,
    required super.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: NotificationType.fromString(map['type'] as String?),
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      data: (map['data'] as Map?)?.cast<String, dynamic>(),
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel.fromMap(json);

  factory NotificationModel.fromEntity(AppNotification entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      data: entity.data,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  /// ⚠️ `type.value` (snake_case) — وليس `type.name` — كي يُقرأ في `fromMap`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toUpdateJson() => {'is_read': isRead};
}