import 'package:equatable/equatable.dart';

/// Authentication BLoC events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check authentication status on app start.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to sign in with email and password.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign up with email and password.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String university;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.university,
  });

  @override
  List<Object?> get props => [email, password, fullName, university];
}

/// Event to sign in with Google.
class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

/// Event to sign out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event to reset password.
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}
