import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/booking_entity.dart';
import '../entities/session_entity.dart';
import '../entities/session_with_profile.dart';

/// Abstract sessions repository.
abstract class SessionRepository {
  /// The bookings of [userId] (with
  /// their embedded sessions), newest
  /// booking first.
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(
    String userId,
  );

  /// The published sessions (with
  /// their publisher profiles),
  /// soonest first.
  Future<Either<Failure, List<SessionEntity>>> getSessions();

  /// The sessions published by
  /// [publisherId] (with their
  /// publisher profiles), newest
  /// first.
  Future<Either<Failure, List<SessionEntity>>> getSessionsByPublisher(
    String publisherId,
  );

  /// A single session with full publisher + category + booking info.
  /// Used by the session-details screen.
  Future<Either<Failure, SessionWithProfile>> getSessionById(
    String sessionId,
  );

  /// Creates a new session in the
  /// sessions table and returns the
  /// created [SessionEntity] on success,
  /// [Failure] on error.
  Future<Either<Failure, SessionEntity>> createSession({
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
  });

  /// Updates an existing session. Returns the updated
  /// [SessionEntity] on success, [Failure] on error.
  Future<Either<Failure, SessionEntity>> updateSession({
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
  });

  /// Books a seat for the current user
  /// in the session identified by [sessionId].
  /// Returns Right(null) on success,
  /// [Failure] on error.
  Future<Either<Failure, void>> bookSession({required String sessionId});

  /// Cancels the current user's booking
  /// for the session identified by [sessionId].
  /// Returns Right(null) on success,
  /// [Failure] on error.
  Future<Either<Failure, void>> cancelBooking({required String sessionId});
}