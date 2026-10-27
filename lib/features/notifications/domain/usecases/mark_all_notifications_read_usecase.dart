import '../repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository _repo;
  const MarkAllNotificationsReadUseCase(this._repo);

  Future<void> call() => _repo.markAllAsRead();
}
