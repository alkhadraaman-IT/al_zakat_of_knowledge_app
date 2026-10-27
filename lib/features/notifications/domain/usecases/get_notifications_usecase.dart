import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repo;
  const GetNotificationsUseCase(this._repo);

  Future<List<AppNotification>> call({int limit = 50, int offset = 0}) =>
      _repo.getNotifications(limit: limit, offset: offset);
}
