import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../repositories/study_tool_repository.dart';

class DeleteStudyToolUseCase {
  final StudyToolRepository repository;
  const DeleteStudyToolUseCase(this.repository);

  Future<Either<Failure, void>> call({required String toolId}) {
    print('<<<<<<<<<<<[DeleteStudyToolUseCase.call]>>>>>>>>>>>>>');
    return repository.deleteStudyTool(toolId: toolId);
  }
}