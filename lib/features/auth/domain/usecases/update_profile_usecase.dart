import '../../../../core/utils/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for updating the logged-in user's profile row.
class UpdateProfileUseCase {
  final AuthRepository repository;

  const UpdateProfileUseCase(this.repository);

  Future<Either<Failure, ProfileEntity>> call(ProfileEntity profile) {
    print('<<<<<<<<<<<[UpdateProfileUseCase.call]>>>>>>>>>>>>>');
    return repository.updateProfile(profile);
  }
}
