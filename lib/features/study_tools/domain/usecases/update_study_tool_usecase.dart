import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';
import '../repositories/study_tool_repository.dart';

class UpdateStudyToolUseCase {
  final StudyToolRepository repository;
  const UpdateStudyToolUseCase(this.repository);

  Future<Either<Failure, StudyToolEntity>> call({
    required String toolId,
    required String title,
    required String subject,
    required String studyYear,
    required String university,
    required String city,
    required String pickupPlace,
    required String pickupNotes,
    required int categoryId,
    required String kind,
  }) {
    print('<<<<<<<<<<<[UpdateStudyToolUseCase.call]>>>>>>>>>>>>>');
    return repository.updateStudyTool(
      toolId: toolId,
      title: title,
      subject: subject,
      studyYear: studyYear,
      university: university,
      city: city,
      pickupPlace: pickupPlace,
      pickupNotes: pickupNotes,
      categoryId: categoryId,
      kind: kind,
    );
  }
}