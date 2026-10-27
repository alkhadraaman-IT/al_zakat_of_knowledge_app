import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';
import '../repositories/study_tool_repository.dart';

/// Use case for listing the offered study
/// tools, newest first.
class GetStudyToolsUseCase {
  final StudyToolRepository repository;

  const GetStudyToolsUseCase(this.repository);

  Future<Either<Failure, List<StudyToolEntity>>> call() {
    print('<<<<<<<<<<<[GetStudyToolsUseCase.call]>>>>>>>>>>>>>');
    return repository.getStudyTools();
  }
}
