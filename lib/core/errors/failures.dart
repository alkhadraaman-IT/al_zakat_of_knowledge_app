import 'package:equatable/equatable.dart';

/// Base failure class for all domain-level errors.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server-side failure (Supabase errors, 500s, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Cache/local storage failure (Hive, SharedPreferences)
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Network connectivity failure
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Authentication failure (invalid credentials, unauthorized)
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Input validation failure
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

/// Unexpected/unknown failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message, super.code});
}
