import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/study_tool_repository.dart';

class TakeStudyToolUseCase {
  final StudyToolRepository repository;
  const TakeStudyToolUseCase(this.repository);

  Future<Either<Failure, void>> call({required String toolId}) {
    return repository.takeStudyTool(toolId: toolId);
  }
}