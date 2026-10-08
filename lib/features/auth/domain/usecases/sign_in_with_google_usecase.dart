import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Google SSO.
class SignInWithGoogleUseCase {
  final AuthRepository repository;

  const SignInWithGoogleUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() {
    print('<<<<<<<<<<<[SignInWithGoogleUseCase.call]>>>>>>>>>>>>>');
    return repository.signInWithGoogle();
  }
}
