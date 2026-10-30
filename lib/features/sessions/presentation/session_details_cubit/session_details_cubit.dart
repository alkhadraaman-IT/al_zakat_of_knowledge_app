import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/session_with_profile.dart';
import '../../domain/usecases/get_session_by_id_usecase.dart';
import 'session_details_state.dart';

class SessionDetailsCubit extends Cubit<SessionDetailsState> {
  final GetSessionByIdUseCase getSessionByIdUseCase;
  final String sessionId;

  SessionDetailsCubit({
    required this.getSessionByIdUseCase,
    required this.sessionId,
  }) : super(const SessionDetailsInitial());

  Future<void> load() async {
    print('<<<<<<<<<<<[SessionDetailsCubit.load]>>>>>>>>>>>>>');
    emit(const SessionDetailsLoading());
    final result = await getSessionByIdUseCase(sessionId);
    result.fold(
      (f) => emit(SessionDetailsError(message: f.message, code: f.code)),
      (details) => emit(SessionDetailsLoaded(details: details)),
    );
  }

  Future<void> refresh() async {
    final current = state;
    if (current is SessionDetailsLoaded) {
      // Reload quietly — keep existing data visible
      final result = await getSessionByIdUseCase(sessionId);
      result.fold(
        (_) {}, // Keep current
        (details) => emit(SessionDetailsLoaded(details: details)),
      );
    } else {
      await load();
    }
  }

  /// يُستدعى من BlocListener<BookingCubit> عند نجاح الحجز/الإلغاء
  /// لتحديث `isBooked` و `bookedCount` بدون طلب شبكة كامل.
  void onBookingChanged({required bool isBooked}) {
    final current = state;
    if (current is! SessionDetailsLoaded) return;

    final details = current.details;
    final newCount = details.session.bookedCount + (isBooked ? 1 : -1);

    emit(SessionDetailsLoaded(
      details: details.copyWith(
        session: details.session.copyWith(bookedCount: newCount),
        isBooked: isBooked,
      ),
    ));
  }
}