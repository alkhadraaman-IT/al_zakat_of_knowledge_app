import 'package:equatable/equatable.dart';

/// States for the booking flow.
sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no booking action in progress.
class BookingInitial extends BookingState {
  const BookingInitial();
}

/// A booking or cancellation request is in flight.
class BookingLoading extends BookingState {
  const BookingLoading();
}

/// The booking or cancellation succeeded.
class BookingSuccess extends BookingState {
  final bool isBooked;

  const BookingSuccess({required this.isBooked});

  @override
  List<Object?> get props => [isBooked];
}

/// An error occurred during booking or cancellation.
class BookingError extends BookingState {
  final String message;
  final String? code;

  const BookingError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}