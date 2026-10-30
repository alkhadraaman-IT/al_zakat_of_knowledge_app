import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_failure.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import 'notification_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _get;
  final WatchLocalNotificationChangesUseCase _watch;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _delete;

  StreamSubscription<void>? _sub;
  bool _isLoading = false;

  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required WatchLocalNotificationChangesUseCase watchLocalChanges,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
  })  : _get = getNotifications,
        _watch = watchLocalChanges,
        _markRead = markRead,
        _markAllRead = markAllRead,
        _delete = deleteNotification,
        super(const NotificationsState());

  void start() {
    if (state.status != NotificationsStatus.initial) return;
    _sub = _watch().listen((_) => _load());
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> retry() => _load();

  Future<void> _load() async {
    if (_isLoading) return;
    _isLoading = true;

    if (state.notifications.isEmpty) {
      emit(state.copyWith(status: NotificationsStatus.loading));
    }

    try {
      final r = await _get();
      if (isClosed) return;
      emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: r.items,
        partialFailure: r.remoteFailure,
        clearFailure: true,
      ));
    } on NotificationsException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        failure: e.kind,
      ));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        failure: NotificationsFailureKind.unknown,
      ));
    } finally {
      _isLoading = false;
    }
  }

  Future<void> markAsRead(String id) async {
    final updatedList = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    emit(state.copyWith(notifications: updatedList));
    await _markRead(id);
  }

  Future<void> markAllAsRead() async {
    final updatedList =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(state.copyWith(notifications: updatedList));
    await _markAllRead();
  }

  Future<void> delete(String id) async {
    final updatedList =
        state.notifications.where((n) => n.id != id).toList();
    emit(state.copyWith(notifications: updatedList));
    await _delete(id);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}