import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/booking_entity.dart';
import '../repositories/session_repository.dart';

/// Use case for listing the bookings
/// of a user (with their embedded
/// sessions), newest booking first.
class GetUserBookingsUseCase {
  final SessionRepository sessionRepository;

  const GetUserBookingsUseCase(this.sessionRepository);

  Future<Either<Failure, List<BookingEntity>>> call({
    required String userId,
  }) {
    print('<<<<<<<<<<<[GetUserBookingsUseCase.call]>>>>>>>>>>>>>');
    return sessionRepository.getUserBookings(userId);
  }
}
