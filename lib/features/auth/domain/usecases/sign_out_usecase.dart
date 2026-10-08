import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out the current user.
class SignOutUseCase {
  final AuthRepository repository;

  const SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    print('<<<<<<<<<<<[SignOutUseCase.call]>>>>>>>>>>>>>');
    return repository.signOut();
  }
}
