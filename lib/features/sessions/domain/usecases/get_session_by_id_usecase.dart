import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/session_with_profile.dart';
import '../repositories/session_repository.dart';

class GetSessionByIdUseCase {
  final SessionRepository repository;

  const GetSessionByIdUseCase(this.repository);

  Future<Either<Failure, SessionWithProfile>> call(String sessionId) {
    print('<<<<<<<<<<<[GetSessionByIdUseCase.call]>>>>>>>>>>>>>');
    return repository.getSessionById(sessionId);
  }
}