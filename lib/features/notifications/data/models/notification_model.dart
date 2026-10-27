import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: NotificationType.fromString(json['type'] as String?),
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      data: (json['data'] as Map?)?.cast<String, dynamic>(),
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // لا يوجد toInsertJson: الإنشاء من الخادم فقط.
  // التعديل المسموح من التطبيق: is_read فقط.
  Map<String, dynamic> toUpdateJson() => {'is_read': isRead};
}
