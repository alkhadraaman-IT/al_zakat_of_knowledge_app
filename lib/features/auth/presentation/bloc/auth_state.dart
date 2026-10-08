import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Authentication BLoC states.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state with user data.
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error state.
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Password reset email sent successfully.
class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}
