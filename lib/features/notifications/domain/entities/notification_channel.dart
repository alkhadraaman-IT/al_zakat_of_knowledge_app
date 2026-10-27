import 'notification_type.dart';

/// كيف يصل الإشعار؟
enum NotificationChannel {
  /// رسالة FCM لتوكن مستخدم محدّد (أحداث الحجز).
  fcmToken,

  /// رسالة FCM لـ topic تصنيف (محتوى جديد).
  fcmTopic,

  /// تنبيه مجدول محلياً على الجهاز (بدون خادم).
  localSchedule,
}

/// أين يُحفظ ليظهر بالقائمة؟
enum NotificationStorage {
  /// جدول notifications بـ Supabase (يكتبه trigger بالخادم).
  serverTable,

  /// Hive على الجهاز.
  deviceOnly,

  /// لا يظهر بالقائمة.
  none,
}

/// ماذا يحدث عند وصوله غير العرض؟
enum NotificationSideEffect {
  none,
  rescheduleReminder,
  cancelSessionAlarms,
}

class NotificationBehavior {
  final NotificationChannel channel;
  final NotificationStorage storage;
  final NotificationSideEffect sideEffect;

  /// هل يظهر شريط داخل التطبيق عند وصوله والتطبيق مفتوح؟
  final bool showInAppBanner;

  const NotificationBehavior({
    required this.channel,
    required this.storage,
    this.sideEffect = NotificationSideEffect.none,
    this.showInAppBanner = true,
  });
}

/// تعريف صريح لسلوك كل نوع. أي نوع جديد = حالة جديدة هنا (المترجم يفرض ذلك).
extension NotificationTypeBehavior on NotificationType {
  NotificationBehavior get behavior => switch (this) {
        // ── أحداث الحجز: توكن المستخدم + صف بالخادم ──
        NotificationType.sessionCancelled => const NotificationBehavior(
            channel: NotificationChannel.fcmToken,
            storage: NotificationStorage.serverTable,
            sideEffect: NotificationSideEffect.cancelSessionAlarms,
          ),
        NotificationType.sessionUpdated => const NotificationBehavior(
            channel: NotificationChannel.fcmToken,
            storage: NotificationStorage.serverTable,
            sideEffect: NotificationSideEffect.rescheduleReminder,
          ),
        NotificationType.materialTaken => const NotificationBehavior(
            channel: NotificationChannel.fcmToken,
            storage: NotificationStorage.serverTable,
          ),

        // ── محتوى جديد: topic التصنيف + حفظ محلي ──
        NotificationType.newSession ||
        NotificationType.newMaterial ||
        NotificationType.newArticle =>
          const NotificationBehavior(
            channel: NotificationChannel.fcmTopic,
            storage: NotificationStorage.deviceOnly,
          ),

        // ── مجدولة محلياً: تُسجَّل بالقائمة مسبقاً بوقت المستقبل، ولا شريط داخل التطبيق ──
        NotificationType.sessionEndedDua ||
        NotificationType.sessionReminder =>
          const NotificationBehavior(
            channel: NotificationChannel.localSchedule,
            storage: NotificationStorage.deviceOnly,
            showInAppBanner: false,
          ),

        // ── نوع غير معروف: شريط فقط، لا يُحفظ ──
        NotificationType.system => const NotificationBehavior(
            channel: NotificationChannel.fcmToken,
            storage: NotificationStorage.none,
          ),
      };
}
