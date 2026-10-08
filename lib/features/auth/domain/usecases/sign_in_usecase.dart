import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password.
class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) {
    print('<<<<<<<<<<<[SignInUseCase.call]>>>>>>>>>>>>>');
    return repository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
