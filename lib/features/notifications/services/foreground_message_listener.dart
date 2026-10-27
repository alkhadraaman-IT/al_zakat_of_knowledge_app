import 'dart:async';

import '../data/datasources/fcm_data_source.dart';
import 'incoming_message_pipeline.dart';

/// يستمع لرسائل FCM والتطبيق مفتوح ويمرّرها للمسار.
class ForegroundMessageListener {
  final FcmDataSource _fcm;
  final IncomingMessagePipeline _pipeline;
  ForegroundMessageListener(this._fcm, this._pipeline);

  StreamSubscription<Map<String, dynamic>>? _sub;

  void start() {
    _sub ??= _fcm.onMessage
        .listen((d) => _pipeline.process(d, fromForeground: true));
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}
