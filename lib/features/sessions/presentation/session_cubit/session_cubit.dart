import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../../domain/usecases/create_session_usecase.dart';
import 'session_state.dart';

/// Cubit الخاص بإدارة المحاضرات وعمليات الإنشاء والجلب
class SessionCubit extends Cubit<SessionState> {
  final GetSessionsUseCase getSessionsUseCase;
  final CreateSessionUseCase createSessionUseCase;

  SessionCubit({
    required this.getSessionsUseCase,
    required this.createSessionUseCase,
  }) : super(const SessionInitial());

  /// جلب قائمة المحاضرات
  Future<void> getSessions() async {
    print('<<<<<<<<<<<[SessionCubit.getSessions]>>>>>>>>>>>>>');
    emit(const SessionLoading());
    final result = await getSessionsUseCase();
    result.fold(
      (failure) {
        print('<<<<<<<<<<<[getSessions Error]>>>>>>>>>>>>>');
        print('Message: ${failure.message}');
        emit(SessionError(message: failure.message, code: failure.code));
      },
      (sessions) => emit(SessionsLoaded(sessions: sessions)),
    );
  }

  /// إنشاء محاضرة جديدة باحترافية
  Future<void> createSession({
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
  }) async {
    print('<<<<<<<<<<<[SessionCubit.createSession]>>>>>>>>>>>>>');
    emit(const SessionSubmitting());
    
    final result = await createSessionUseCase(
      publisherId: publisherId,
      title: title,
      description: description,
      categoryId: categoryId,
      city: city,
      placeName: placeName,
      startsAt: startsAt,
      durationMinutes: durationMinutes,
      maxSeats: maxSeats,
      lat: lat,
      lng: lng,
    );

    result.fold(
      (failure) {
        print('<<<<<<<<<<<[createSession Error]>>>>>>>>>>>>>');
        print('Message: ${failure.message}');
        emit(SessionError(message: failure.message, code: failure.code));
      },
      (session) {
        print('<<<<<<<<<<<[createSession Success]>>>>>>>>>>>>>');
        emit(SessionSuccess(session: session));
        getSessions(); // إعادة جلب القائمة لتحديث الواجهة تلقائياً
      },
    );
  }
}