import '../errors/failures.dart';

/// Functional programming Either type for error handling.
/// Left = Failure, Right = Success value.
sealed class Either<L, R> {
  const Either();

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      onLeft(value);
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) =>
      onRight(value);
}

/// Type alias for common use case: `Either<Failure, T>`
typedef Result<T> = Either<Failure, T>;
