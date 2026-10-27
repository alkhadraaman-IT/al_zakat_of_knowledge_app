import 'session_entity.dart';

/// Domain entity for a booking
/// (a `bookings` table row) with
/// its embedded `sessions` row.
class BookingEntity {
  final String id;
  final String sessionId;
  final String userId;
  final String status;

  /// ISO 8601 booking time (`booked_at`).
  final String bookedAt;

  /// ISO 8601 cancellation time
  /// (`cancelled_at`), `null` while
  /// the booking is active.
  final String? cancelledAt;
  final SessionEntity session;

  const BookingEntity({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.status,
    required this.bookedAt,
    this.cancelledAt,
    required this.session,
  });
}
