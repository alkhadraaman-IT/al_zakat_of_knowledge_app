import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart'; // تأكد من مسار الملف (مفرد أو جمع)
import '../../domain/entities/notifications_result.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/incoming_message_bus.dart';
import '../datasources/notification_local_data_source.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remote;
  final NotificationsLocalDataSource _local;
  final IncomingMessageBus _bus;
  final String? Function() currentUserId;
  final Duration _localRetention = const Duration(days: 30);

  // أدوات التحكم في التحديث (Debounce) لمنع التجميد
  Timer? _debounceTimer;
  final StreamController<void> _changesController = StreamController<void>.broadcast();
  StreamSubscription? _localSub;
  StreamSubscription? _busSub;

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remote,
    required NotificationsLocalDataSource local,
    required IncomingMessageBus bus,
    required this.currentUserId,
  })  : _remote = remote,
        _local = local,
        _bus = bus {
    // الاستماع للتغييرات وإضافة تأخير 500 مللي ثانية لكسر الحلقة المفرغة
    _localSub = _local.watch().listen((_) => _triggerChange());
    _busSub = _bus.changes.listen((_) => _triggerChange());
  }

  void _triggerChange() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_changesController.isClosed) {
        _changesController.add(null);
      }
    });
  }

  @override
  Stream<void> watchChanges() => _changesController.stream;

  @override
  Future<NotificationsResult> getNotifications({int limit = 50}) async {
    final uid = currentUserId();
    if (uid == null) {
      return const NotificationsResult([]); // استخدام positional argument
    }

    // 1. تنظيف الإشعارات القديمة محلياً
    await _local.deleteOlderThan(_localRetention);

    NotificationsFailureKind? remoteFailure;

    // 2. جلب الإشعارات الجديدة من السيرفر
    try {
      final remoteModels = await _remote.fetch(limit: limit);
      // استخدام حلقة تكرار لحفظ كل عنصر لأن دالة الحفظ تأخذ عنصراً واحداً
      for (final model in remoteModels) {
        await _local.save(model);
      }
    } catch (e) {
      debugPrint('Error fetching remote notifications: $e');
      remoteFailure = _mapError(e);
    }

    // 3. قراءة القائمة النهائية من الذاكرة المحلية
    final finalLocalModels = _local.getAll(uid);
    
    // بما أن NotificationModel يرث من AppNotification، يمكننا تمريره مباشرة
    return NotificationsResult(
      finalLocalModels, // positional argument
      remoteFailure: remoteFailure,
    );
  }

  @override
  Future<void> markAsRead(String id) async {
    await _local.markAsRead(id);
    try {
      await _remote.markAsRead(id);
    } catch (e) {
      debugPrint('Failed to mark read on remote: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final uid = currentUserId();
    if (uid == null) return;

    await _local.markAllAsRead(uid);
    try {
      await _remote.markAllAsRead();
    } catch (e) {
      debugPrint('Failed to mark all read on remote: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    try {
      await _remote.delete(id);
    } catch (e) {
      debugPrint('Failed to delete on remote: $e');
    }
  }

  @override
  Future<void> saveLocal(AppNotification notification) async {
    final model = NotificationModel.fromEntity(notification);
    await _local.save(model);
  }

  @override
  Future<void> removeLocal(String id) async {
    await _local.delete(id);
  }

  NotificationsFailureKind _mapError(Object e) {
    if (e is SocketException || e is TimeoutException) {
      return NotificationsFailureKind.network;
    }
    if (e is PostgrestException || e is AuthException) {
      return NotificationsFailureKind.server;
    }
    return NotificationsFailureKind.unknown;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _localSub?.cancel();
    _busSub?.cancel();
    _changesController.close();
  }
}