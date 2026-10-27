import 'dart:async';

import '../../domain/entities/incoming_message.dart';

/// ناقل داخل التطبيق (في الذاكرة):
///  - [banners]: رسائل تُعرض كشريط مرئي والتطبيق مفتوح.
///  - [changes]: "تغيّر شيء" لتحديث القائمة تلقائياً.
class IncomingMessageBus {
  final _banners = StreamController<IncomingMessage>.broadcast();
  final _changes = StreamController<void>.broadcast();

  Stream<IncomingMessage> get banners => _banners.stream;
  Stream<void> get changes => _changes.stream;

  void showBanner(IncomingMessage m) => _banners.add(m);
  void notifyChanged() => _changes.add(null);
}
