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

  // الإنشاء من Map (fromMap)
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: NotificationType.fromString(map['type'] as String?),
      title: (map['title'] as String?) ?? '',
      body: (map['body'] as String?) ?? '',
      data: (map['data'] as Map?)?.cast<String, dynamic>(),
      isRead: (map['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
    );
  }

  // دعم fromJson كمرادف لـ fromMap للتوافق
  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
      NotificationModel.fromMap(json);

  // الإنشاء من الـ Entity (لحل مشكلة fromEntity المفقودة)
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

  // التحويل إلى Map (toMap)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name, // تأكد من مطابقة طريقة حفظ النوع لديك (مثل استخدام .name لو كان Enum)
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // دعم toJson كمرادف لـ toMap
  Map<String, dynamic> toJson() => toMap();

  // التعديل المسموح من التطبيق: is_read فقط.
  Map<String, dynamic> toUpdateJson() => {'is_read': isRead};
}