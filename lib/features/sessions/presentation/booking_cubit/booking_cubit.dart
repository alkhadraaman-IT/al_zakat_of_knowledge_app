import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/book_session_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import 'booking_state.dart';

/// Cubit managing seat booking and cancellation for a session.
///
/// Exposes `bookSession` and `cancelBooking` which invoke the
/// corresponding UseCases and emit states reflecting the result.
class BookingCubit extends Cubit<BookingState> {
  final BookSessionUseCase bookSessionUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingCubit({
    required this.bookSessionUseCase,
    required this.cancelBookingUseCase,
  }) : super(const BookingInitial());

  /// Books a seat in the session identified by [sessionId].
  ///
  /// Emits [BookingLoading] while the RPC is in progress,
  /// then [BookingSuccess] on success or [BookingError] on failure.
  Future<void> bookSession(String sessionId) async {
    print('<<<<<<<<<<<[BookingCubit.bookSession]>>>>>>>>>>>>>');
    emit(const BookingLoading());

    final result = await bookSessionUseCase(sessionId: sessionId);

    result.fold(
      (failure) {
        print('<<<<<<<<<<<[bookSession Error]>>>>>>>>>>>>>');
        print('Message: ${failure.message}');
        emit(BookingError(message: failure.message, code: failure.code));
      },
      (_) {
        print('<<<<<<<<<<<[bookSession Success]>>>>>>>>>>>>>');
        emit(const BookingSuccess(isBooked: true));
      },
    );
  }

  /// Cancels the current user's booking for [sessionId].
  ///
  /// Emits [BookingLoading] while the RPC is in progress,
  /// then [BookingSuccess] on success or [BookingError] on failure.
  Future<void> cancelBooking(String sessionId) async {
    print('<<<<<<<<<<<[BookingCubit.cancelBooking]>>>>>>>>>>>>>');
    emit(const BookingLoading());

    final result = await cancelBookingUseCase(sessionId: sessionId);

    result.fold(
      (failure) {
        print('<<<<<<<<<<<[cancelBooking Error]>>>>>>>>>>>>>');
        print('Message: ${failure.message}');
        emit(BookingError(message: failure.message, code: failure.code));
      },
      (_) {
        print('<<<<<<<<<<<[cancelBooking Success]>>>>>>>>>>>>>');
        emit(const BookingSuccess(isBooked: false));
      },
    );
  }
}