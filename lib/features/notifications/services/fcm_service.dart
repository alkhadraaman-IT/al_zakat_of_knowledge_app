import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../data/datasources/device_tokens_remote_data_source.dart';
import '../data/datasources/fcm_data_source.dart';
import '../data/datasources/local_notifications_data_source.dart';
import '../data/datasources/pending_messages_data_source.dart';
import '../data/models/incoming_message_parser.dart';
import '../data/repositories/notification_scheduler_impl.dart';
import '../domain/repositories/notification_scheduler.dart';
import '../domain/usecases/handle_incoming_notification_usecase.dart';
import '../domain/usecases/sync_category_topics_usecase.dart';

/// تنسيق FCM على مستوى التطبيق (composition): توكن، topics، رسائل التطبيق المفتوح،
/// وتفريغ طابور رسائل الخلفية.
class FcmService with WidgetsBindingObserver {
  final FcmDataSource _fcm;
  final DeviceTokensRemoteDataSource _tokens;
  final LocalNotificationsDataSource _local;
  final PendingMessagesDataSource _pending;
  final HandleIncomingNotificationUseCase _handle;
  final SyncCategoryTopicsUseCase _syncTopics;
  final NotificationScheduler _scheduler;
  final String? Function() _currentUserId;

  FcmService({
    required FcmDataSource fcm,
    required DeviceTokensRemoteDataSource tokens,
    required LocalNotificationsDataSource local,
    required PendingMessagesDataSource pending,
    required HandleIncomingNotificationUseCase handle,
    required SyncCategoryTopicsUseCase syncTopics,
    required NotificationScheduler scheduler,
    required String? Function() currentUserId,
  })  : _fcm = fcm,
        _tokens = tokens,
        _local = local,
        _pending = pending,
        _handle = handle,
        _syncTopics = syncTopics,
        _scheduler = scheduler,
        _currentUserId = currentUserId;

  StreamSubscription<String>? _tokenSub;
  StreamSubscription<Map<String, dynamic>>? _msgSub;
  bool _started = false;

  Future<void> _guarded(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      debugPrint('FcmService: $e'); // لا نكسر الإقلاع بسبب شبكة أو إذن
    }
  }

  /// بعد تسجيل الدخول (وعند كل إقلاع والمستخدم مسجّل).
  /// [followedCategoryIds]: التصنيفات المتابَعة حالياً (من category_follows).
  Future<void> start({required Set<String> followedCategoryIds}) async {
    await _pending.setCurrentUserId(_currentUserId());

    await _guarded(_fcm.requestPermission);
    await _guarded(_registerToken);

    if (!_started) {
      _started = true;
      _tokenSub = _fcm.onTokenRefresh.listen(
        (t) => _guarded(() => _tokens.register(token: t, platform: Platform.operatingSystem)),
      );
      _msgSub = _fcm.onMessage.listen((d) => _process(d, show: true));
      WidgetsBinding.instance.addObserver(this);
    }

    await _guarded(() => _syncTopics(followedCategoryIds));
    await drainPending();
  }

  /// استدعِها *قبل* signOut (وإلا ترفض RLS حذف التوكن).
  Future<void> stop() async {
    _started = false;
    await _tokenSub?.cancel();
    await _msgSub?.cancel();
    _tokenSub = _msgSub = null;
    WidgetsBinding.instance.removeObserver(this);

    await _guarded(() => _syncTopics(const {}));
    await _guarded(() async {
      final t = await _fcm.getToken();
      if (t != null) await _tokens.remove(t);
    });
    await _guarded(_fcm.deleteToken);
    await _guarded(_syncTopics.clear); // الاشتراكات ضاعت مع التوكن
    await _guarded(_scheduler.cancelAll);
    await _pending.setCurrentUserId(null);
  }

  /// معالجة رسائل وصلت والتطبيق بالخلفية أو مغلقاً.
  Future<void> drainPending() async {
    for (final data in await _pending.takeAll()) {
      await _process(data, show: false); // التنبيه عُرض سابقاً بالخلفية
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) drainPending();
  }

  Future<void> _registerToken() async {
    final t = await _fcm.getToken();
    if (t != null) await _tokens.register(token: t, platform: Platform.operatingSystem);
  }
Future<void> _process(Map<String, dynamic> data, {required bool show}) async {
    final m = IncomingMessageParser.tryParse(data);
    if (m == null) return;
    if (m.publisherId != null && m.publisherId == _currentUserId()) return;

    if (show) {
      await _guarded(() => _local.show(
            id: NotificationSchedulerImpl.idFor(m.id),
            title: m.title,
            body: m.body,
            payload: m.target?.toPayload(),
          ));
    }
    await _guarded(() => _handle(m));
  }
}
