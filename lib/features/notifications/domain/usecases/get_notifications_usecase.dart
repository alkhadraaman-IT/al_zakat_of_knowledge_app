import '../entities/notifications_result.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationsRepository _repo;
  const GetNotificationsUseCase(this._repo);

  Future<NotificationsResult> call({int limit = 50}) =>
      _repo.getNotifications(limit: limit);
}
