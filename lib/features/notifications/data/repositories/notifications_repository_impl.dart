import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_data_source.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;
  final NotificationsLocalDataSource _local;
  final String? Function() _currentUserId;

  /// الإشعارات المحلية الأقدم من هذه المدة تُحذف تلقائياً.
  static const _localRetention = Duration(days: 30);

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remote,
    required NotificationsLocalDataSource local,
    required String? Function() currentUserId,
  })  : _remote = remote,
        _local = local,
        _currentUserId = currentUserId;

  String get _uid =>
      _currentUserId() ?? (throw const NotificationsException('not_authenticated'));

  NotificationsException _map(Object e) {
    if (e is NotificationsException) return e;
    if (e is PostgrestException) return NotificationsException(e.message);
    if (e is AuthException) return NotificationsException(e.message);
    return const NotificationsException('network_error');
  }

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    final uid = _uid;
    await _local.deleteOlderThan(_localRetention);
    // إشعارات مجدولة (دعاء/تذكير) موقّتة بالمستقبل: تظهر فقط عند حلول وقتها
    final now = DateTime.now();
    final local = _local
        .getAll(uid)
        .where((n) => !n.createdAt.isAfter(now))
        .toList();

    var remote = <NotificationModel>[];
    try {
      remote = await _remote.fetch(limit: limit);
    } catch (e) {
      // بدون إنترنت: نعرض المحلي. نفشل فقط إن لم يوجد شيء نعرضه.
      if (local.isEmpty) throw _map(e);
    }

    final all = <AppNotification>[...remote, ...local]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all.take(limit).toList();
  }

  @override
  Future<void> markAsRead(String id) {
    if (_local.contains(id)) return _local.markAsRead(id);
    return _guard(() => _remote.markAsRead(id));
  }

  @override
  Future<void> markAllAsRead() async {
    final uid = _uid;
    // الخادم أولاً: إن فشل لا نغيّر شيئاً والواجهة تتراجع بشكل متسق.
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
      _local.save(NotificationModel.fromEntity(notification, userId: _uid));

  @override
  Future<void> removeLocal(String id) => _local.delete(id);

  @override
  Stream<void> watchLocalChanges() => _local.watch();
}
