import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_failure.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import 'notification_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _get;
  final WatchLocalNotificationChangesUseCase _watchChanges;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _delete;

  StreamSubscription<void>? _sub;

  /// آخر عملية فشلت (تحديد كمقروء/حذف...) لزر إعادة المحاولة.
  Future<void> Function()? _retryAction;

  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required WatchLocalNotificationChangesUseCase watchLocalChanges,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
  })  : _get = getNotifications,
        _watchChanges = watchLocalChanges,
        _markRead = markRead,
        _markAllRead = markAllRead,
        _delete = deleteNotification,
        super(const NotificationsState());

  /// يحمّل القائمة ثم يحدّثها تلقائياً عند أي تغيير (رسالة وصلت، تغيّر محلي).
  Future<void> start() async {
    _retryAction = null;
    emit(state.copyWith(status: NotificationsStatus.loading));
    await _load();
    _sub ??= _watchChanges().listen((_) => _load());
  }

  Future<void> refresh() => _load();

  /// زر "إعادة المحاولة": يعيد آخر عملية فاشلة، أو تحميل القائمة.
  Future<void> retry() {
    final action = _retryAction;
    return action != null ? action() : start();
  }

  Future<void> _load() async {
    try {
      final r = await _get();
      if (isClosed) return;
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: r.items,
        partialFailure: r.remoteFailure,
      ));
    } on NotificationsException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: NotificationsStatus.failure, failure: e.kind));
    }
  }

  Future<void> markAsRead(String id) => _mutate(
        apply: (l) => l.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
        action: () => _markRead(id),
        retry: () => markAsRead(id),
      );

  Future<void> markAllAsRead() => _mutate(
        apply: (l) => l.map((n) => n.copyWith(isRead: true)).toList(),
        action: () => _markAllRead(),
        retry: markAllAsRead,
      );

  Future<void> delete(String id) => _mutate(
        apply: (l) => l.where((n) => n.id != id).toList(),
        action: () => _delete(id),
        retry: () => delete(id),
      );

  /// تحديث متفائل ثم تراجع + تسجيل "إعادة المحاولة" إن فشلت العملية.
  Future<void> _mutate({
    required List<AppNotification> Function(List<AppNotification>) apply,
    required Future<void> Function() action,
    required Future<void> Function() retry,
  }) async {
    final prev = state.notifications;
    emit(state.copyWith(
      status: NotificationsStatus.success,
      notifications: apply(prev),
      partialFailure: state.partialFailure,
    ));
    try {
      await action();
      _retryAction = null;
    } on NotificationsException catch (e) {
      if (isClosed) return;
      _retryAction = retry;
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        notifications: prev,
        failure: e.kind,
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
