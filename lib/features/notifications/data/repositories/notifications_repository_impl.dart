import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart';
import '../../domain/entities/notifications_result.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/incoming_message_bus.dart';
import '../datasources/notification_local_datasource.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;
  final NotificationsLocalDataSource _local;
  final IncomingMessageBus _bus;
  final String? Function() _currentUserId;

  static const _localRetention = Duration(days: 30);

  /// بدون مهلة يبقى المستخدم أمام مؤشر تحميل طويل عند ضعف الشبكة.
  static const _remoteTimeout = Duration(seconds: 12);

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remote,
    required NotificationsLocalDataSource local,
    required IncomingMessageBus bus,
    required String? Function() currentUserId,
  })  : _remote = remote,
        _local = local,
        _bus = bus,
        _currentUserId = currentUserId;

  String get _uid => _currentUserId() ??
      (throw const NotificationsException(NotificationsFailureKind.unauthenticated));

  /// يحوّل أي خطأ تقني إلى نوع مفهوم للمستخدم.
  NotificationsException _map(Object e) {
    if (e is NotificationsException) return e;
    if (e is TimeoutException) {
      return NotificationsException(NotificationsFailureKind.network, details: '$e');
    }
    if (e is AuthException) {
      return NotificationsException(NotificationsFailureKind.unauthenticated,
          details: e.message);
    }
    if (e is PostgrestException) {
      final code = e.code ?? '';
      final msg = e.message.toLowerCase();
      if (code == '42501') {
        return NotificationsException(NotificationsFailureKind.permissionDenied,
            details: e.message);
      }
      if (code == 'PGRST301' || code == 'PGRST303' || msg.contains('jwt')) {
        return NotificationsException(NotificationsFailureKind.unauthenticated,
            details: e.message);
      }
      return NotificationsException(NotificationsFailureKind.server, details: e.message);
    }
    final s = e.toString();
    if (s.contains('SocketException') ||
        s.contains('ClientException') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection')) {
      return NotificationsException(NotificationsFailureKind.network, details: s);
    }
    return NotificationsException(NotificationsFailureKind.unknown, details: s);
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call().timeout(_remoteTimeout);
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<NotificationsResult> getNotifications({int limit = 50}) async {
    final uid = _uid;
    await _local.deleteOlderThan(_localRetention);

    // المجدولة (دعاء/تذكير) موقّتة بالمستقبل: تظهر عند حلول وقتها فقط
    final now = DateTime.now();
    final local =
        _local.getAll(uid).where((n) => !n.createdAt.isAfter(now)).toList();

    var remote = <NotificationModel>[];
    NotificationsFailureKind? remoteFailure;
    try {
      remote = await _remote.fetch(limit: limit).timeout(_remoteTimeout);
    } catch (e) {
      final mapped = _map(e);
      // لا شيء نعرضه: فشل كامل. وإلا نعرض المحلي ونُخبر المستخدم أن التحديث فشل.
      if (local.isEmpty) throw mapped;
      remoteFailure = mapped.kind;
    }

    final all = <AppNotification>[...remote, ...local]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return NotificationsResult(all.take(limit).toList(), remoteFailure: remoteFailure);
  }

  @override
  Future<void> markAsRead(String id) {
    if (_local.contains(id)) return _local.markAsRead(id);
    return _guard(() => _remote.markAsRead(id));
  }

@override
  Future<void> markAllAsRead() async {
    final uid = _uid;
    // الخادم أولاً: إن فشل لا نغيّر شيئاً والواجهة تتراجع بشكل متسق
    await _guard(_remote.markAllAsRead);
    await _local.markAllAsRead(uid);
  }

  @override
  Future<void> delete(String id) {
    if (_local.contains(id)) return _local.delete(id);
    return _guard(() => _remote.delete(id));
  }

  @override
  Future<void> saveLocal(AppNotification notification) =>
      _local.save(NotificationModel.fromEntity(notification));

  @override
  Future<void> removeLocal(String id) => _local.delete(id);

  @override
  Stream<void> watchChanges() {
    late final StreamController<void> controller;
    StreamSubscription<void>? a;
    StreamSubscription<void>? b;
    controller = StreamController<void>(
      onListen: () {
        a = _local.watch().listen((_) => controller.add(null));
        b = _bus.changes.listen((_) => controller.add(null));
      },
      onCancel: () async {
        await a?.cancel();
        await b?.cancel();
      },
    );
    return controller.stream;
  }
}
