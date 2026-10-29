import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';

abstract class StudyToolRepository {
  Future<Either<Failure, List<StudyToolEntity>>> getStudyTools();

  Future<Either<Failure, List<StudyToolEntity>>> getStudyToolsByOwner(
    String ownerId,
  );

  Future<Either<Failure, StudyToolEntity>> createStudyTool({
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
  });

  Future<Either<Failure, StudyToolEntity>> updateStudyTool({
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
  });

  Future<Either<Failure, void>> deleteStudyTool({required String toolId});

  Future<Either<Failure, void>> takeStudyTool({required String toolId});
}