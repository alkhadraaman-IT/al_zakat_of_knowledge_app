import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/session_repository.dart';

/// Use case for cancelling a booking
/// via the `cancel_booking` Supabase RPC.
/// Returns `Right(null)` on success,
/// [Failure] on error.
class CancelBookingUseCase {
  final SessionRepository sessionRepository;

  const CancelBookingUseCase(this.sessionRepository);

  Future<Either<Failure, void>> call({required String sessionId}) {
    print('<<<<<<<<<<<[CancelBookingUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.cancelBooking(sessionId: sessionId);
  }
}