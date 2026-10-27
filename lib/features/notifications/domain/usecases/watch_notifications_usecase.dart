import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class WatchNotificationsUseCase {
  final NotificationsRepository _repo;
  const WatchNotificationsUseCase(this._repo);

  Stream<List<AppNotification>> call({int limit = 50}) =>
      _repo.watchNotifications(limit: limit);
}
