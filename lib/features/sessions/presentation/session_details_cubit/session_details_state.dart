import 'package:equatable/equatable.dart';

import '../../domain/entities/session_with_profile.dart';

sealed class SessionDetailsState extends Equatable {
  const SessionDetailsState();

  @override
  List<Object?> get props => [];
}

class SessionDetailsInitial extends SessionDetailsState {
  const SessionDetailsInitial();
}

class SessionDetailsLoading extends SessionDetailsState {
  const SessionDetailsLoading();
}

class SessionDetailsLoaded extends SessionDetailsState {
  final SessionWithProfile details;

  const SessionDetailsLoaded({required this.details});

  @override
  List<Object?> get props => [details];
}

class SessionDetailsError extends SessionDetailsState {
  final String message;
  final String? code;

  const SessionDetailsError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}