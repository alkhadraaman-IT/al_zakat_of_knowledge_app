import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

/// Use case for listing the sessions
/// published by a publisher, with
/// their publisher profiles embedded,
/// newest first.
class GetSessionsByPublisherUseCase {
  final SessionRepository sessionRepository;

  const GetSessionsByPublisherUseCase(this.sessionRepository);

  Future<Either<Failure, List<SessionEntity>>> call({
    required String publisherId,
  }) {
    print('<<<<<<<<<<<[GetSessionsByPublisherUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.getSessionsByPublisher(publisherId);
  }
}
