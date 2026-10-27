import 'package:equatable/equatable.dart';
import '../../domain/entities/session_entity.dart';

/// حالات الـ Session BLoC / Cubit
sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SessionInitial extends SessionState {
  const SessionInitial();
}

/// حالة التحميل العامة
class SessionLoading extends SessionState {
  const SessionLoading();
}

/// تم جلب المحاضرات بنجاح
class SessionsLoaded extends SessionState {
  final List<SessionEntity> sessions;

  const SessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

/// حالة إرسال/إنشاء محاضرة جديدة
class SessionSubmitting extends SessionState {
  const SessionSubmitting();
}

/// تم إنشاء المحاضرة بنجاح
class SessionSuccess extends SessionState {
  final SessionEntity session;

  const SessionSuccess({required this.session});

  @override
  List<Object?> get props => [session];
}

/// حالة الخطأ
class SessionError extends SessionState {
  final String message;
  final String? code;

  const SessionError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}