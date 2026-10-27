import 'package:firebase_messaging/firebase_messaging.dart';

class FcmDataSource {
  final FirebaseMessaging _fm;
  FcmDataSource(this._fm);

  Future<void> requestPermission() => _fm.requestPermission();
  Future<String?> getToken() => _fm.getToken();
  Future<void> deleteToken() => _fm.deleteToken();
  Stream<String> get onTokenRefresh => _fm.onTokenRefresh;

  /// رسائل التطبيق المفتوح (foreground). الخلفية يعالجها fcmBackgroundHandler.
  Stream<Map<String, dynamic>> get onMessage =>
      FirebaseMessaging.onMessage.map((m) => m.data);

  Future<void> subscribe(String topic) => _fm.subscribeToTopic(topic);
  Future<void> unsubscribe(String topic) => _fm.unsubscribeFromTopic(topic);
}
