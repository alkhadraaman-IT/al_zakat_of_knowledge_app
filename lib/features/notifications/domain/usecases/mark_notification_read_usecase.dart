import '../repositories/notification_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repo;
  const MarkNotificationReadUseCase(this._repo);

  Future<void> call(String id) => _repo.markAsRead(id);
}