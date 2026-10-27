import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';
import '../repositories/study_tool_repository.dart';

/// Use case for offering a new study
/// material in the `materials` table.
class CreateStudyToolUseCase {
  final StudyToolRepository repository;

  const CreateStudyToolUseCase(this.repository);

  Future<Either<Failure, StudyToolEntity>> call({
    required String ownerId,
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
    print('<<<<<<<<<<<[CreateStudyToolUseCase.call]>>>>>>>>>>>>>');
    return repository.createStudyTool(
      ownerId: ownerId,
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
