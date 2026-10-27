import 'package:flutter/widgets.dart';

import '../data/datasources/pending_messages_data_source.dart';
import 'incoming_message_pipeline.dart';

/// يفرغ طابور الرسائل التي وصلت والتطبيق بالخلفية أو مغلقاً، عند الإقلاع
/// وكل مرة يعود فيها التطبيق للواجهة.
class PendingMessagesDrainer with WidgetsBindingObserver {
  final PendingMessagesDataSource _pending;
  final IncomingMessagePipeline _pipeline;
  PendingMessagesDrainer(this._pending, this._pipeline);

  bool _active = false;

  void start() {
    if (_active) return;
    _active = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    _active = false;
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> drain() async {
    for (final data in await _pending.takeAll()) {
      await _pipeline.process(data, fromForeground: false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) drain();
  }
}
