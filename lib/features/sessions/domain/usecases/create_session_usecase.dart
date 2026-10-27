import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

/// Use case for creating a new
/// session in the sessions table.
/// Returns the created [SessionEntity]
/// on success.
class CreateSessionUseCase {
  final SessionRepository sessionRepository;

  const CreateSessionUseCase(this.sessionRepository);

  Future<Either<Failure, SessionEntity>> call({
    required String publisherId,
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
    print('<<<<<<<<<<<[CreateSessionUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.createSession(
      publisherId: publisherId,
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