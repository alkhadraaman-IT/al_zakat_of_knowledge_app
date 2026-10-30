import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// غلاف حول flutter_local_notifications (مكتوب لإصدار ^22).
class LocalNotificationsDataSource {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static final _android = AndroidNotificationDetails(
    'zakat_sessions',
    'notifications.channel_name'.tr(),
    channelDescription: 'notifications.channel_description'.tr(),
    importance: Importance.high,
    priority: Priority.high,
  );

  /// استدعِها مرة واحدة بالـ main. [onTap] يستلم payload (= sessionId).
  Future<void> init({required void Function(String? payload) onTap}) async {
    tzdata.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // الصلاحية نطلبها لاحقاً بوقت مناسب، لا عند الإقلاع
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) => onTap(r.payload),
    );

    // التطبيق كان مغلقاً وفُتح بالضغط على التنبيه
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      WidgetsBinding.instance.addPostFrameCallback((_) => onTap(payload));
    }
  }

  /// تهيئة خفيفة لـ isolate الخلفية (بدون tap ولا timezone).
  Future<void> initForBackground() => _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );

  /// عرض فوري (لرسائل FCM).
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: _android,
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  /// أندرويد 13+ وiOS يحتاجان إذناً. يرجع false إن رفضه المستخدم.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final a = await android?.requestNotificationsPermission();
    final i = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return a ?? i ?? true;
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    String? payload,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // لحظة مطلقة بـ UTC: لا نحتاج حزمة المنطقة الزمنية ولا يؤثر التوقيت الصيفي
      scheduledDate: tz.TZDateTime.from(when, tz.UTC),
      notificationDetails: NotificationDetails(
        android: _android,
        iOS: DarwinNotificationDetails(),
      ),
      // inexact: لا يحتاج إذن "المنبهات الدقيقة"، وقد يتأخر دقائق قليلة
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);
  Future<void> cancelAll() => _plugin.cancelAll();
}
