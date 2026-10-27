import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';
import '../repositories/study_tool_repository.dart';

/// Use case for listing the study
/// materials offered by an owner
/// (the `materials` table, filtered
/// by `owner_id`), newest first.
class GetStudyToolsByOwnerUseCase {
  final StudyToolRepository repository;

  const GetStudyToolsByOwnerUseCase(this.repository);

  Future<Either<Failure, List<StudyToolEntity>>> call({
    required String ownerId,
  }) {
    print('<<<<<<<<<<<[GetStudyToolsByOwnerUseCase.call]>>>>>>>>>>>>>');
    return repository.getStudyToolsByOwner(ownerId);
  }
}
