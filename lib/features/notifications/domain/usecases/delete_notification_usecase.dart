import '../repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationsRepository _repo;
  const DeleteNotificationUseCase(this._repo);

  Future<void> call(String id) => _repo.delete(id);
}
