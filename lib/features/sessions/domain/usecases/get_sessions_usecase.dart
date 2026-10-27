import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/session_entity.dart';
import '../repositories/session_repository.dart';

/// Use case for listing the
/// published sessions, with their
/// publisher profiles embedded,
/// soonest first.
class GetSessionsUseCase {
  final SessionRepository sessionRepository;

  const GetSessionsUseCase(this.sessionRepository);

  Future<Either<Failure, List<SessionEntity>>> call() {
    print('<<<<<<<<<<<[GetSessionsUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.getSessions();
  }
}
