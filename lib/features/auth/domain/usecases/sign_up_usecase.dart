import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing up with email and password.
class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
    required String fullName,
    required String university,
  }) {
    print('<<<<<<<<<<<[SignUpUseCase.call]>>>>>>>>>>>>>');
    return repository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      fullName: fullName,
      university: university,
    );
  }
}
