import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for reading the logged-in user's profile row
/// (fresh from the backend, with a local-cache fallback).
class GetCurrentProfileUseCase {
  final AuthRepository repository;

  const GetCurrentProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity?>> call() {
    print('<<<<<<<<<<<[GetCurrentProfileUseCase.call]>>>>>>>>>>>>>');
    return repository.getCurrentProfile();
  }
}
