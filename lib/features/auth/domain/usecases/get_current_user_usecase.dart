import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call() {
    print('<<<<<<<<<<<[GetCurrentUserUseCase.call]>>>>>>>>>>>>>');
    return repository.getCurrentUser();
  }
}
