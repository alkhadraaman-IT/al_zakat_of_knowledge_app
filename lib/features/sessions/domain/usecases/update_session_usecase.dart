import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

class UpdateSessionUseCase {
  final SessionRepository sessionRepository;
  const UpdateSessionUseCase(this.sessionRepository);

  Future<Either<Failure, SessionEntity>> call({
    required String sessionId,
    required String title,
    required String description,
    required int categoryId,
    required String city,
    required String placeName,
    required String startsAt,
    required int durationMinutes,
    required int maxSeats,
    required double lat,
    required double lng,
  }) {
    return sessionRepository.updateSession(
      sessionId: sessionId,
      title: title,
      description: description,
      categoryId: categoryId,
      city: city,
      placeName: placeName,
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      maxSeats: maxSeats,
      lat: lat,
      lng: lng,
    );
  }
}