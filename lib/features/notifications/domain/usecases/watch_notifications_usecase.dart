import '../repositories/notification_repository.dart';

class WatchLocalNotificationChangesUseCase {
  final NotificationsRepository _repo;
  const WatchLocalNotificationChangesUseCase(this._repo);

  Stream<void> call() => _repo.watchChanges();
}
