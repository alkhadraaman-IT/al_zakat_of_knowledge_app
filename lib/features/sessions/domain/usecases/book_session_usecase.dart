import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/session_repository.dart';

/// Use case for booking a seat in a session
/// via the `book_session` Supabase RPC.
/// Returns `Right(null)` on success,
/// [Failure] on error.
class BookSessionUseCase {
  final SessionRepository sessionRepository;

  const BookSessionUseCase(this.sessionRepository);

  Future<Either<Failure, void>> call({required String sessionId}) {
    print('<<<<<<<<<<<[BookSessionUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.bookSession(sessionId: sessionId);
  }
}