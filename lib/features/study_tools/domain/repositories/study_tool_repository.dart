import '../../../../core/errors/failures.dart';
import '../../../../core/utils/either.dart';
import '../entities/study_tool_entity.dart';

/// Abstract study material repository interface.
abstract class StudyToolRepository {
  /// Lists the offered study materials from
  /// the `materials` table, newest first.
  Future<Either<Failure, List<StudyToolEntity>>> getStudyTools();

  /// Lists the study materials offered
  /// by [ownerId] (the `materials`
  /// table, filtered by `owner_id`),
  /// newest first.
  Future<Either<Failure, List<StudyToolEntity>>> getStudyToolsByOwner(
    String ownerId,
  );

  /// Inserts a new material row in the
  /// `materials` table. Returns the created
  /// [StudyToolEntity] on success, [Failure]
  /// on error.
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
}
