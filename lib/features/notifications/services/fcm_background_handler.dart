import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../data/datasources/local_notifications_data_source.dart';
import '../data/datasources/pending_messages_data_source.dart';
import '../data/models/incoming_message_parser.dart';
import '../data/repositories/notification_scheduler_impl.dart';

/// يعمل بـ isolate منفصل (التطبيق بالخلفية أو مغلق). لا يوجد هنا get_it ولا Supabase.
/// يعرض التنبيه ويضع الرسالة بالطابور؛ التطبيق يعالجها عند فتحه (FcmService.drainPending).
/// سجّله بالـ main: FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();

  final m = IncomingMessageParser.tryParse(message.data);
  if (m == null) return;

  final pending = PendingMessagesDataSource();
  final uid = await pending.currentUserId();
  if (uid == null) return; // لا مستخدم مسجّل
  if (m.publisherId != null && m.publisherId == uid) return; // لا ننبّه ناشر المحتوى نفسه

  final local = LocalNotificationsDataSource();
  await local.initForBackground();
  await local.show(
    id: NotificationSchedulerImpl.idFor(m.id),
    title: m.title,
    body: m.body,
    payload: m.target?.toPayload(),
  );

  await pending.enqueue(message.data);
}
