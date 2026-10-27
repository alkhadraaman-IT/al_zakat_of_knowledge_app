import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/watch_notifications_usecase.dart';
import 'notification_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final GetNotificationsUseCase _get;
  final WatchNotificationsUseCase _watch;
  final MarkNotificationReadUseCase _markRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _delete;

  StreamSubscription<List<AppNotification>>? _sub;

  NotificationsCubit({
    required GetNotificationsUseCase getNotifications,
    required WatchNotificationsUseCase watchNotifications,
    required MarkNotificationReadUseCase markRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
  })  : _get = getNotifications,
        _watch = watchNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead,
        _delete = deleteNotification,
        super(const NotificationsState());

  /// يبدأ الاستماع للقائمة (يصل أول snapshot ثم أي إشعار جديد فوراً).
  void start() {
    emit(state.copyWith(status: NotificationsStatus.loading));
    _sub?.cancel();
    _sub = _watch().listen(
      (items) => emit(
        state.copyWith(status: NotificationsStatus.success, notifications: items),
      ),
      onError: (Object e) => emit(
        state.copyWith(status: NotificationsStatus.failure, errorMessage: _code(e)),
      ),
    );
  }

  /// سحب للتحديث (pull to refresh).
  Future<void> refresh() async {
    try {
      final items = await _get();
      emit(state.copyWith(status: NotificationsStatus.success, notifications: items));
    } on NotificationsException catch (e) {
      emit(state.copyWith(status: NotificationsStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> markAsRead(String id) async {
    final prev = state.notifications;
    emit(state.copyWith(
      notifications:
          prev.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    ));
    try {
      await _markRead(id);
    } on NotificationsException catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        notifications: prev,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> markAllAsRead() async {
    final prev = state.notifications;
    emit(state.copyWith(
      notifications: prev.map((n) => n.copyWith(isRead: true)).toList(),
    ));
    try {
      await _markAllRead();
    } on NotificationsException catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        notifications: prev,
        errorMessage: e.message,
      ));
    }
  }

  Future<void> delete(String id) async {
    final prev = state.notifications;
    emit(state.copyWith(notifications: prev.where((n) => n.id != id).toList()));
    try {
      await _delete(id);
    } on NotificationsException catch (e) {
      emit(state.copyWith(
        status: NotificationsStatus.failure,
        notifications: prev,
        errorMessage: e.message,
      ));
    }
  }

  String _code(Object e) => e is NotificationsException ? e.message : 'network_error';

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
